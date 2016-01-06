#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>

#include "config.h"
#include "cmark.h"
#include "node.h"
#include "buffer.h"
#include "utf8.h"
#include "scanners.h"
#include "render.h"

#define safe_strlen(s) cmark_strbuf_safe_strlen(s)
#define OUT(s, wrap, escaping) renderer->out(renderer, s, wrap, escaping)
#define LIT(s) renderer->out(renderer, s, false, LITERAL)
#define CR() renderer->cr(renderer)
#define BLANKLINE() renderer->blankline(renderer)

// Functions to convert cmark_nodes to commonmark strings.

static inline void outc(cmark_renderer *renderer,
                        cmark_escaping escape,
                        int32_t c,
                        unsigned char nextc)
{
	bool needs_escaping = false;
	needs_escaping =
	    escape != LITERAL &&
	    ((escape == NORMAL &&
	      (c == '*' || c == '_' || c == '[' || c == ']' || c == '#' ||
	       c == '<' || c == '>' || c == '\\' || c == '`' || c == '!' ||
	       (c == '&' && isalpha(nextc)) ||
	       (c == '!' && nextc == '[') ||
	       (renderer->begin_line &&
	        (c == '-' || c == '+' || c == '=')) ||
	       ((c == '.' || c == ')') &&
	        isdigit(renderer->buffer->ptr[renderer->buffer->size - 1])))) ||
	     (escape == URL &&
	      (c == '`' || c == '<' || c == '>' || isspace(c) ||
	       c == '\\' || c == ')' || c == '(')) ||
	     (escape == TITLE &&
	      (c == '`' || c == '<' || c == '>' || c == '"' ||
	       c == '\\')));

	if (needs_escaping) {
		if (isspace(c)) {
			// use percent encoding for spaces
			cmark_strbuf_printf(renderer->buffer, "%%%2x", c);
			renderer->column += 3;
		} else {
			cmark_render_ascii(renderer, "\\");
			cmark_render_code_point(renderer, c);
		}
	} else {
		cmark_render_code_point(renderer, c);
	}
}

static int
longest_backtick_sequence(const char *code)
{
	int longest = 0;
	int current = 0;
	size_t i = 0;
	size_t code_len = safe_strlen(code);
	while (i <= code_len) {
		if (code[i] == '`') {
			current++;
		} else {
			if (current > longest) {
				longest = current;
			}
			current = 0;
		}
		i++;
	}
	return longest;
}

static int
shortest_unused_backtick_sequence(const char *code)
{
	int32_t used = 1;
	int current = 0;
	size_t i = 0;
	size_t code_len = safe_strlen(code);
	while (i <= code_len) {
		if (code[i] == '`') {
			current++;
		} else {
			if (current) {
				used |= (1 << current);
			}
			current = 0;
		}
		i++;
	}
	// return number of first bit that is 0:
	i = 0;
	while (used & 1) {
		used = used >> 1;
		i++;
	}
	return i;
}

static bool
is_autolink(cmark_node *node)
{
	cmark_chunk *title;
	cmark_chunk *url;
	cmark_node *link_text;
	char *realurl;
	int realurllen;

	if (node->type != CMARK_NODE_LINK) {
		return false;
	}

	url = &node->as.link.url;
	if (url->len == 0 || scan_scheme(url, 0) == 0) {
		return false;
	}

	title = &node->as.link.title;
	// if it has a title, we can't treat it as an autolink:
	if (title->len > 0) {
		return false;
	}

	link_text = node->first_child;
	cmark_consolidate_text_nodes(link_text);
	realurl = (char*)url->data;
	realurllen = url->len;
	if (strncmp(realurl, "mailto:", 7) == 0) {
		realurl += 7;
		realurllen -= 7;
	}
	return (realurllen == link_text->as.literal.len &&
	        strncmp(realurl,
	                (char*)link_text->as.literal.data,
	                link_text->as.literal.len) == 0);
}

// if node is a block node, returns node.
// otherwise returns first block-level node that is an ancestor of node.
static cmark_node*
get_containing_block(cmark_node *node)
{
	while (node &&
	       (node->type < CMARK_NODE_FIRST_BLOCK ||
	        node->type > CMARK_NODE_LAST_BLOCK)) {
		node = node->parent;
	}
	return node;
}

static int
S_render_node(cmark_renderer *renderer,
              cmark_node *node,
              cmark_event_type ev_type,
              int options)
{
	cmark_node *tmp;
	int list_number;
	cmark_delim_type list_delim;
	int numticks;
	int i;
	bool entering = (ev_type == CMARK_EVENT_ENTER);
	const char *info, *code, *title;
	size_t info_len, code_len;
	cmark_strbuf listmarker = GH_BUF_INIT;
	char *emph_delim;
	bufsize_t marker_width;

	// Don't adjust tight list status til we've started the list.
	// Otherwise we loose the blank line between a paragraph and
	// a following list.
	if (!(node->type == CMARK_NODE_ITEM && node->prev == NULL &&
	      entering)) {
		tmp = get_containing_block(node);
		renderer->in_tight_list_item =
		    (tmp->type == CMARK_NODE_ITEM &&
		     cmark_node_get_list_tight(tmp->parent)) ||
		    (tmp &&
		     tmp->parent &&
		     tmp->parent->type == CMARK_NODE_ITEM &&
		     cmark_node_get_list_tight(tmp->parent->parent));
	}

	switch (node->type) {
	case CMARK_NODE_DOCUMENT:
		break;

	case CMARK_NODE_BLOCK_QUOTE:
		if (entering) {
			LIT("> ");
			cmark_strbuf_puts(renderer->prefix, "> ");
		} else {
			cmark_strbuf_truncate(renderer->prefix,
			                      renderer->prefix->size - 2);
			BLANKLINE();
		}
		break;

	case CMARK_NODE_LIST:
		if (!entering && node->next &&
		    (node->next->type == CMARK_NODE_CODE_BLOCK ||
		     node->next->type == CMARK_NODE_LIST)) {
			// this ensures 2 blank lines after list,
			// if before code block or list:
			LIT("\n");
		}
		break;

	case CMARK_NODE_ITEM:
		if (cmark_node_get_list_type(node->parent) ==
		    CMARK_BULLET_LIST) {
			marker_width = 2;
		} else {
			list_number = cmark_node_get_list_start(node->parent);
			list_delim = cmark_node_get_list_delim(node->parent);
			tmp = node;
			while (tmp->prev) {
				tmp = tmp->prev;
				list_number += 1;
			}
			// we ensure a width of at least 4 so
			// we get nice transition from single digits
			// to double
			cmark_strbuf_printf(&listmarker,
			                    "%d%s%s", list_number,
			                    list_delim == CMARK_PAREN_DELIM ?
			                    ")" : ".",
			                    list_number < 10 ? "  " : " ");
			marker_width = listmarker.size;
		}
		if (entering) {
			if (cmark_node_get_list_type(node->parent) ==
			    CMARK_BULLET_LIST) {
				LIT("* ");
				cmark_strbuf_puts(renderer->prefix, "  ");
			} else {
				LIT((char *)listmarker.ptr);
				for (i = marker_width; i--;) {
					cmark_strbuf_putc(renderer->prefix, ' ');
				}
			}
		} else {
			cmark_strbuf_truncate(renderer->prefix,
			                      renderer->prefix->size -
			                      marker_width);
			CR();
		}
		cmark_strbuf_free(&listmarker);
		break;

	case CMARK_NODE_HEADER:
		if (entering) {
			for (int i = cmark_node_get_header_level(node); i > 0; i--) {
				LIT("#");
			}
			LIT(" ");
			renderer->no_wrap = true;
		} else {
			renderer->no_wrap = false;
			BLANKLINE();
		}
		break;

	case CMARK_NODE_CODE_BLOCK:
		BLANKLINE();
		info = cmark_node_get_fence_info(node);
		info_len = safe_strlen(info);
		code = cmark_node_get_literal(node);
		code_len = safe_strlen(code);
		// use indented form if no info, and code doesn't
		// begin or end with a blank line, and code isn't
		// first thing in a list item
		if (info_len == 0 &&
		    (code_len > 2 &&
		     !isspace(code[0]) &&
		     !(isspace(code[code_len - 1]) &&
		       isspace(code[code_len - 2]))) &&
		    !(node->prev == NULL && node->parent &&
		      node->parent->type == CMARK_NODE_ITEM)) {
			LIT("    ");
			cmark_strbuf_puts(renderer->prefix, "    ");
			OUT(cmark_node_get_literal(node), false, LITERAL);
			cmark_strbuf_truncate(renderer->prefix,
			                      renderer->prefix->size - 4);
		} else {
			numticks = longest_backtick_sequence(code) + 1;
			if (numticks < 3) {
				numticks = 3;
			}
			for (i = 0; i < numticks; i++) {
				LIT("`");
			}
			LIT(" ");
			OUT(info, false, LITERAL);
			CR();
			OUT(cmark_node_get_literal(node), false, LITERAL);
			CR();
			for (i = 0; i < numticks; i++) {
				LIT("`");
			}
		}
		BLANKLINE();
		break;

	case CMARK_NODE_HTML:
		BLANKLINE();
		OUT(cmark_node_get_literal(node), false, LITERAL);
		BLANKLINE();
		break;

	case CMARK_NODE_HRULE:
		BLANKLINE();
		LIT("-----");
		BLANKLINE();
		break;

	case CMARK_NODE_PARAGRAPH:
		if (!entering) {
			BLANKLINE();
		}
		break;

	case CMARK_NODE_TEXT:
		OUT(cmark_node_get_literal(node), true, NORMAL);
		break;

	case CMARK_NODE_LINEBREAK:
		if (!(CMARK_OPT_HARDBREAKS & options)) {
			LIT("\\");
		}
		CR();
		break;

	case CMARK_NODE_SOFTBREAK:
		if (renderer->width == 0 &&
		    !(CMARK_OPT_HARDBREAKS & options)) {
			CR();
		} else {
			OUT(" ", true, LITERAL);
		}
		break;

	case CMARK_NODE_CODE:
		code = cmark_node_get_literal(node);
		code_len = safe_strlen(code);
		numticks = shortest_unused_backtick_sequence(code);
		for (i = 0; i < numticks; i++) {
			LIT("`");
		}
		if (code_len == 0 || code[0] == '`') {
			LIT(" ");
		}
		OUT(cmark_node_get_literal(node), true, LITERAL);
		if (code_len == 0 || code[code_len - 1] == '`') {
			LIT(" ");
		}
		for (i = 0; i < numticks; i++) {
			LIT("`");
		}
		break;

	case CMARK_NODE_INLINE_HTML:
		OUT(cmark_node_get_literal(node), false, LITERAL);
		break;

	case CMARK_NODE_STRONG:
		if (entering) {
			LIT("**");
		} else {
			LIT("**");
		}
		break;

	case CMARK_NODE_EMPH:
		// If we have EMPH(EMPH(x)), we need to use *_x_*
		// because **x** is STRONG(x):
		if (node->parent && node->parent->type == CMARK_NODE_EMPH &&
		    node->next == NULL && node->prev == NULL) {
			emph_delim = "_";
		} else {
			emph_delim = "*";
		}
		if (entering) {
			LIT(emph_delim);
		} else {
			LIT(emph_delim);
		}
		break;

	case CMARK_NODE_LINK:
		if (is_autolink(node)) {
			if (entering) {
				LIT("<");
				if (strncmp(cmark_node_get_url(node),
				            "mailto:", 7) == 0) {
					LIT((char *)cmark_node_get_url(node) + 7);
				} else {
					LIT((char *)cmark_node_get_url(node));
				}
				LIT(">");
				// return signal to skip contents of node...
				return 0;
			}
		} else {
			if (entering) {
				LIT("[");
			} else {
				LIT("](");
				OUT(cmark_node_get_url(node), false, URL);
				title = cmark_node_get_title(node);
				if (safe_strlen(title) > 0) {
					LIT(" \"");
					OUT(title, false, TITLE);
					LIT("\"");
				}
				LIT(")");
			}
		}
		break;

	case CMARK_NODE_IMAGE:
		if (entering) {
			LIT("![");
		} else {
			LIT("](");
			OUT(cmark_node_get_url(node), false, URL);
			title = cmark_node_get_title(node);
			if (safe_strlen(title) > 0) {
				OUT(" \"", true, LITERAL);
				OUT(title, false, TITLE);
				LIT("\"");
			}
			LIT(")");
		}
		break;

	default:
		assert(false);
		break;
	}

	return 1;
}

char *cmark_render_commonmark(cmark_node *root, int options, int width)
{
	if (options & CMARK_OPT_HARDBREAKS) {
		// disable breaking on width, since it has
		// a different meaning with OPT_HARDBREAKS
		width = 0;
	}
	return cmark_render(root, options, width, outc, S_render_node);
}
