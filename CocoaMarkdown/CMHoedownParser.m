//
//  CMHoedownParser.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/19/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHoedownParser.h"
#import "CMParserDelegateFlags.h"
#import "document.h"

#import <libkern/OSAtomic.h>

inline NSString * str(const hoedown_buffer *buf) {
    if (buf == NULL || buf->size == 0) return nil;
    return [[NSString alloc] initWithBytes:buf->data length:buf->size encoding:NSUTF8StringEncoding];
}

inline bool emptybuf(const hoedown_buffer *buf) {
    return buf == NULL || buf->size == 0;
}

@interface CMHoedownParser () {
    @public
    CMParserDelegateFlags _delegateFlags;
    __weak id<CMParserDelegate> _delegate;
}
@end

#define DEF_SELF CMHoedownParser *self = (__bridge CMHoedownParser *)data->opaque
#define DELEGATE_HAS(x) self->_delegateFlags.x

static void RenderBlockCode(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *lang, const hoedown_renderer_data *data)
{
    if (emptybuf(text)) return;
    
    DEF_SELF;
    if (DELEGATE_HAS(foundCodeBlock)) {
        [self->_delegate parser:self foundCodeBlock:str(text) info:str(lang)];
    }
}

static int RenderInlineCode(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data)
{
    if (emptybuf(text)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(foundInlineCode)) {
        [self->_delegate parser:self foundInlineCode:str(text)];
    }
    
    return 1;
}

static void RenderBlockQuote(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartBlockQuote)) {
        [self->_delegate parserDidStartBlockQuote:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndBlockQuote)) {
        [self->_delegate parserDidEndBlockQuote:self];
    }
}

static int RenderInlineQuote(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(foundInlineQuote)) {
        [self->_delegate parser:self foundInlineQuote:str(content)];
    }
    
    return 1;
}

static int RenderStrikethrough(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartStrikethrough)) {
        [self->_delegate parserDidStartStrikethrough:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndStrikethrough)) {
        [self->_delegate parserDidEndStrikethrough:self];
    }
    
    return 1;
}

static int RenderStrong(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartStrong)) {
        [self->_delegate parserDidStartStrong:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndStrong)) {
        [self->_delegate parserDidEndStrong:self];
    }
    
    return 1;
}

static int RenderEmphasis(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartEmphasis)) {
        [self->_delegate parserDidStartEmphasis:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndEmphasis)) {
        [self->_delegate parserDidEndEmphasis:self];
    }
    
    return 1;
}

static int RenderStrongEmphasis(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartEmphasis)) {
        [self->_delegate parserDidStartEmphasis:self];
    }
    if (DELEGATE_HAS(didStartStrong)) {
        [self->_delegate parserDidStartStrong:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndStrong)) {
        [self->_delegate parserDidEndStrong:self];
    }
    if (DELEGATE_HAS(didEndEmphasis)) {
        [self->_delegate parserDidEndEmphasis:self];
    }
    
    return 1;
}

static int RenderSuperscript(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartSuperscript)) {
        [self->_delegate parserDidStartSuperscript:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndSuperscript)) {
        [self->_delegate parserDidEndSuperscript:self];
    }
    
    return 1;
}

static int RenderUnderline(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartUnderline)) {
        [self->_delegate parserDidStartUnderline:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndUnderline)) {
        [self->_delegate parserDidEndUnderline:self];
    }
    
    return 1;
}

static int RenderHighlight(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartHighlight)) {
        [self->_delegate parserDidStartHighlight:self];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndHighlight)) {
        [self->_delegate parserDidEndHighlight:self];
    }
    
    return 1;
}

static int RenderLinebreak(hoedown_buffer *ob, const hoedown_renderer_data *data)
{
    DEF_SELF;
    if (DELEGATE_HAS(foundLineBreak)) {
        [self->_delegate parserFoundLineBreak:self];
    }
    return 1;
}

static void RenderHeader(hoedown_buffer *ob, const hoedown_buffer *content, int level, const hoedown_renderer_data *data)
{
    if (emptybuf(content)) return;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartHeader)) {
        [self->_delegate parser:self didStartHeaderWithLevel:level];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndHeader)) {
        [self->_delegate parser:self didEndHeaderWithLevel:level];
    }
}

static int RenderAutolink(hoedown_buffer *ob, const hoedown_buffer *link, hoedown_autolink_type type, const hoedown_renderer_data *data)
{
    if (emptybuf(link)) return 0;
    
    NSURL *URL = [NSURL URLWithString:str(link)];
    if (URL == nil) return 0;
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartLink)) {
        [self->_delegate parser:self didStartLinkWithURL:URL title:nil];
    }
    
    NSString *text = nil;
    if (hoedown_buffer_prefix(link, "mailto:") == 0) {
        text = [[NSString alloc] initWithBytes:link->data + 7 length:link->size - 7 encoding:NSUTF8StringEncoding];
    } else {
        text = str(link);
    }
    [self->_delegate parser:self foundText:text];
    
    if (DELEGATE_HAS(didEndLink)) {
        [self->_delegate parser:self didEndLinkWithURL:URL title:nil];
    }
    
    return 1;
}

static int RenderLink(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_renderer_data *data)
{
    if (emptybuf(link)) return 0;
    
    NSURL *URL = [NSURL URLWithString:str(link)];
    if (URL == nil) return 0;
    NSString *titleString = str(title);
    
    DEF_SELF;
    if (DELEGATE_HAS(didStartLink)) {
        [self->_delegate parser:self didStartLinkWithURL:URL title:titleString];
    }
    [self->_delegate parser:self foundText:str(content)];
    if (DELEGATE_HAS(didEndLink)) {
        [self->_delegate parser:self didEndLinkWithURL:URL title:titleString];
    }
    
    return 1;
}

static void RenderList(hoedown_buffer *ob, const hoedown_buffer *content, hoedown_list_flags flags, const hoedown_renderer_data *data)
{
//    if (emptybuf(content)) return;
//    
//    const BOOL ordered = (flags & HOEDOWN_LIST_ORDERED) == HOEDOWN_LIST_ORDERED;
//    const BOOL block = (flags & HOEDOWN_LI_BLOCK) == HOEDOWN_LI_BLOCK;
}

static void RenderListItem(hoedown_buffer *ob, const hoedown_buffer *content, hoedown_list_flags flags, const hoedown_renderer_data *data)
{
}

static void RenderParagraph(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
}

static void RenderBlockHTML(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data)
{
}

static int RenderInlineHTML(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data)
{
    return 1;
}

static void RenderText(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
}

static void RenderDocumentHeader(hoedown_buffer *ob, int inline_render, const hoedown_renderer_data *data)
{
    
}

static void RenderDocumentFooter(hoedown_buffer *ob, int inline_render, const hoedown_renderer_data *data)
{
    
}

@implementation CMHoedownParser {
    NSData *_data;
    volatile uint32_t _parsing;
}
@synthesize delegate = _delegate;

#pragma mark - Initialization

- (instancetype)initWithData:(NSData *)data delegate:(id<CMParserDelegate>)delegate
{
    NSParameterAssert(data);
    NSParameterAssert(delegate);
    
    if ((self = [super init])) {
        _data = data;
        _delegate = delegate;
        _delegateFlags = CMParserDelegateFlagsForDelegate(_delegate);
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string delegate:(id<CMParserDelegate>)delegate
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        return [self initWithData:data delegate:delegate];
    }
    return nil;
}

- (instancetype)initWithContentsOfFile:(NSString *)path delegate:(id<CMParserDelegate>)delegate
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data != nil) {
        return [self initWithData:data delegate:delegate];
    }
    return nil;
}

#pragma mark - Parsing

- (void)parse
{
    if (_parsing) return;
    OSAtomicOr32Barrier(1, &_parsing);
    
    static const hoedown_renderer callbacks = {
        NULL,

        RenderBlockCode,
        RenderBlockQuote,
        RenderHeader,
        NULL,
        RenderList,
        RenderListItem,
        RenderParagraph,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        RenderBlockHTML,
        
        RenderAutolink,
        RenderInlineCode,
        RenderStrong,
        RenderEmphasis,
        RenderUnderline,
        RenderHighlight,
        RenderInlineQuote,
        NULL,
        RenderLinebreak,
        RenderLink,
        RenderStrongEmphasis,
        RenderStrikethrough,
        RenderSuperscript,
        NULL,
        NULL,
        RenderInlineHTML,
        
        NULL,
        RenderText,
        
        RenderDocumentHeader,
        RenderDocumentFooter
    };
    static const hoedown_extensions extensions =
        HOEDOWN_EXT_FENCED_CODE  |
        HOEDOWN_EXT_AUTOLINK |
        HOEDOWN_EXT_STRIKETHROUGH |
        HOEDOWN_EXT_UNDERLINE |
        HOEDOWN_EXT_HIGHLIGHT |
        HOEDOWN_EXT_QUOTE |
        HOEDOWN_EXT_SUPERSCRIPT;
    
    hoedown_renderer *renderer = hoedown_malloc(sizeof(hoedown_renderer));
    memcpy(renderer, &callbacks, sizeof(hoedown_renderer));
    renderer->opaque = (__bridge void *)self;
    
    // The output buffer isn't actually used but it has to be
    // specified anyway.
    hoedown_buffer *outputBuffer = hoedown_buffer_new(64);
    hoedown_document *document = hoedown_document_new(renderer, extensions, 16);
    hoedown_document_render(document, outputBuffer, _data.bytes, _data.length);
    
    hoedown_document_free(document);
    hoedown_buffer_free(outputBuffer);
    free(renderer);
    
    OSAtomicAnd32Barrier(0, &_parsing);
}

- (void)abortParsing
{
    if (!_parsing) return;
    OSAtomicAnd32Barrier(0, &_parsing);
    
    if (_delegateFlags.didAbort) {
        [_delegate parserDidAbort:self];
    }
}

@end
