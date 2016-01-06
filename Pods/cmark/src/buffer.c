#include <stdarg.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "config.h"
#include "cmark_ctype.h"
#include "buffer.h"

/* Used as default value for cmark_strbuf->ptr so that people can always
 * assume ptr is non-NULL and zero terminated even for new cmark_strbufs.
 */
unsigned char cmark_strbuf__initbuf[1];

#ifndef MIN
#define MIN(x,y)  ((x<y) ? x : y)
#endif

void cmark_strbuf_init(cmark_strbuf *buf, bufsize_t initial_size)
{
	buf->asize = 0;
	buf->size = 0;
	buf->ptr = cmark_strbuf__initbuf;

	if (initial_size > 0)
		cmark_strbuf_grow(buf, initial_size);
}

void cmark_strbuf_overflow_err()
{
	fprintf(stderr, "String buffer overflow");
	abort();
}

static inline void
S_strbuf_grow_by(cmark_strbuf *buf, size_t add)
{
	size_t target_size = (size_t)buf->size + add;

	if (target_size < add             /* Integer overflow. */
	    || target_size > BUFSIZE_MAX  /* Truncation overflow. */
	   ) {
		cmark_strbuf_overflow_err();
		return; /* unreachable */
	}

	if ((bufsize_t)target_size >= buf->asize)
		cmark_strbuf_grow(buf, (bufsize_t)target_size);
}

void cmark_strbuf_grow(cmark_strbuf *buf, bufsize_t target_size)
{
	unsigned char *new_ptr;

	if (target_size < buf->asize)
		return;

	if (buf->asize == 0) {
		new_ptr = NULL;
	} else {
		new_ptr = buf->ptr;
	}

	/* Oversize the buffer by 50% to guarantee amortized linear time
	 * complexity on append operations. */
	size_t new_size = (size_t)target_size + (size_t)target_size / 2;

	/* Account for terminating null byte. */
	new_size += 1;

	/* round allocation up to multiple of 8 */
	new_size = (new_size + 7) & ~7;

	if (new_size < (size_t)target_size  /* Integer overflow. */
	    || new_size > BUFSIZE_MAX       /* Truncation overflow. */
	   ) {
		if (target_size >= BUFSIZE_MAX) {
			/* No space for terminating null byte. */
			cmark_strbuf_overflow_err();
			return; /* unreachable */
		}
		/* Oversize by the maximum possible amount. */
		new_size = BUFSIZE_MAX;
	}

	new_ptr = (unsigned char *)realloc(new_ptr, new_size);

	if (!new_ptr) {
		perror("realloc in cmark_strbuf_grow");
		abort();
	}

	buf->asize = (bufsize_t)new_size;
	buf->ptr   = new_ptr;
}

bufsize_t cmark_strbuf_len(const cmark_strbuf *buf)
{
	return buf->size;
}

void cmark_strbuf_free(cmark_strbuf *buf)
{
	if (!buf) return;

	if (buf->ptr != cmark_strbuf__initbuf)
		free(buf->ptr);

	cmark_strbuf_init(buf, 0);
}

void cmark_strbuf_clear(cmark_strbuf *buf)
{
	buf->size = 0;

	if (buf->asize > 0)
		buf->ptr[0] = '\0';
}

void cmark_strbuf_set(cmark_strbuf *buf, const unsigned char *data, bufsize_t len)
{
	if (len <= 0 || data == NULL) {
		cmark_strbuf_clear(buf);
	} else {
		if (data != buf->ptr) {
			if (len >= buf->asize)
				cmark_strbuf_grow(buf, len);
			memmove(buf->ptr, data, len);
		}
		buf->size = len;
		buf->ptr[buf->size] = '\0';
	}
}

void cmark_strbuf_sets(cmark_strbuf *buf, const char *string)
{
	cmark_strbuf_set(buf, (const unsigned char *)string,
	                 string ? cmark_strbuf_safe_strlen(string) : 0);
}

void cmark_strbuf_putc(cmark_strbuf *buf, int c)
{
	S_strbuf_grow_by(buf, 1);
	buf->ptr[buf->size++] = c;
	buf->ptr[buf->size] = '\0';
}

void cmark_strbuf_put(cmark_strbuf *buf, const unsigned char *data, bufsize_t len)
{
	if (len <= 0)
		return;

	S_strbuf_grow_by(buf, len);
	memmove(buf->ptr + buf->size, data, len);
	buf->size += len;
	buf->ptr[buf->size] = '\0';
}

void cmark_strbuf_puts(cmark_strbuf *buf, const char *string)
{
	cmark_strbuf_put(buf, (const unsigned char *)string,
	                 cmark_strbuf_safe_strlen(string));
}

void cmark_strbuf_vprintf(cmark_strbuf *buf, const char *format, va_list ap)
{
	size_t expected_size = strlen(format);
	if (expected_size <= SIZE_MAX / 2)
		expected_size *= 2;
	S_strbuf_grow_by(buf, expected_size);

	while (1) {
		va_list args;
		va_copy(args, ap);

		int len = vsnprintf(
		              (char *)buf->ptr + buf->size,
		              buf->asize - buf->size,
		              format, args
		          );
#ifndef HAVE_C99_SNPRINTF
		// Assume we're on Windows.
		if (len < 0) {
			len = _vscprintf(format, args);
		}
#endif

		va_end(args);

		if (len < 0) {
			perror("vsnprintf in cmark_strbuf_vprintf");
			abort();
		}

		if ((size_t)len < (size_t)(buf->asize - buf->size)) {
			buf->size += len;
			break;
		}

		S_strbuf_grow_by(buf, len);
	}
}

void cmark_strbuf_printf(cmark_strbuf *buf, const char *format, ...)
{
	va_list ap;

	va_start(ap, format);
	cmark_strbuf_vprintf(buf, format, ap);
	va_end(ap);
}

void cmark_strbuf_copy_cstr(char *data, bufsize_t datasize, const cmark_strbuf *buf)
{
	bufsize_t copylen;

	assert(buf);
	if (!data || datasize <= 0)
		return;

	data[0] = '\0';

	if (buf->size == 0 || buf->asize <= 0)
		return;

	copylen = buf->size;
	if (copylen > datasize - 1)
		copylen = datasize - 1;
	memmove(data, buf->ptr, copylen);
	data[copylen] = '\0';
}

void cmark_strbuf_swap(cmark_strbuf *buf_a, cmark_strbuf *buf_b)
{
	cmark_strbuf t = *buf_a;
	*buf_a = *buf_b;
	*buf_b = t;
}

unsigned char *cmark_strbuf_detach(cmark_strbuf *buf)
{
	unsigned char *data = buf->ptr;

	if (buf->asize == 0) {
		/* return an empty string */
		return (unsigned char *)calloc(1, 1);
	}

	cmark_strbuf_init(buf, 0);
	return data;
}

int cmark_strbuf_cmp(const cmark_strbuf *a, const cmark_strbuf *b)
{
	int result = memcmp(a->ptr, b->ptr, MIN(a->size, b->size));
	return (result != 0) ? result :
	       (a->size < b->size) ? -1 : (a->size > b->size) ? 1 : 0;
}

bufsize_t cmark_strbuf_strchr(const cmark_strbuf *buf, int c, bufsize_t pos)
{
	if (pos >= buf->size)
		return -1;
	if (pos < 0)
		pos = 0;

	const unsigned char *p = (unsigned char *)memchr(buf->ptr + pos, c, buf->size - pos);
	if (!p)
		return -1;

	return (bufsize_t)(p - (const unsigned char *)buf->ptr);
}

bufsize_t cmark_strbuf_strrchr(const cmark_strbuf *buf, int c, bufsize_t pos)
{
	if (pos < 0 || buf->size == 0)
		return -1;
	if (pos >= buf->size)
		pos = buf->size - 1;

	for (bufsize_t i = pos; i >= 0; i--) {
		if (buf->ptr[i] == (unsigned char) c)
			return i;
	}

	return -1;
}

void cmark_strbuf_truncate(cmark_strbuf *buf, bufsize_t len)
{
	if (len < 0)
		len = 0;

	if (len < buf->size) {
		buf->size = len;
		buf->ptr[buf->size] = '\0';
	}
}

void cmark_strbuf_drop(cmark_strbuf *buf, bufsize_t n)
{
	if (n > 0) {
		if (n > buf->size)
			n = buf->size;
		buf->size = buf->size - n;
		if (buf->size)
			memmove(buf->ptr, buf->ptr + n, buf->size);

		buf->ptr[buf->size] = '\0';
	}
}

void cmark_strbuf_rtrim(cmark_strbuf *buf)
{
	if (!buf->size)
		return;

	while (buf->size > 0) {
		if (!cmark_isspace(buf->ptr[buf->size - 1]))
			break;

		buf->size--;
	}

	buf->ptr[buf->size] = '\0';
}

void cmark_strbuf_trim(cmark_strbuf *buf)
{
	bufsize_t i = 0;

	if (!buf->size)
		return;

	while (i < buf->size && cmark_isspace(buf->ptr[i]))
		i++;

	cmark_strbuf_drop(buf, i);

	cmark_strbuf_rtrim(buf);
}

// Destructively modify string, collapsing consecutive
// space and newline characters into a single space.
void cmark_strbuf_normalize_whitespace(cmark_strbuf *s)
{
	bool last_char_was_space = false;
	bufsize_t r, w;

	for (r = 0, w = 0; r < s->size; ++r) {
		switch (s->ptr[r]) {
		case ' ':
		case '\n':
			if (last_char_was_space)
				break;

			s->ptr[w++] = ' ';
			last_char_was_space = true;
			break;

		default:
			s->ptr[w++] = s->ptr[r];
			last_char_was_space = false;
		}
	}

	cmark_strbuf_truncate(s, w);
}

// Destructively unescape a string: remove backslashes before punctuation chars.
extern void cmark_strbuf_unescape(cmark_strbuf *buf)
{
	bufsize_t r, w;

	for (r = 0, w = 0; r < buf->size; ++r) {
		if (buf->ptr[r] == '\\' && cmark_ispunct(buf->ptr[r + 1]))
			r++;

		buf->ptr[w++] = buf->ptr[r];
	}

	cmark_strbuf_truncate(buf, w);
}
