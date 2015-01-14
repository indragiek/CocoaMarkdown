//
//  CMParser.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMParser.h"
#import "CMDocument.h"
#import "CMIterator.h"
#import "CMNode.h"

#import <libkern/OSAtomic.h>

@interface CMParser ()
@property (nonatomic) BOOL parsing;
@end

@implementation CMParser {
    struct {
        unsigned int didStartDocument:1;
        unsigned int didEndDocument:1;
        unsigned int didAbort:1;
        unsigned int foundText:1;
        unsigned int foundHRule:1;
        unsigned int didStartHeader:1;
        unsigned int didEndHeader:1;
        unsigned int didStartParagraph:1;
        unsigned int didEndParagraph:1;
        unsigned int didStartEmphasis:1;
        unsigned int didEndEmphasis:1;
        unsigned int didStartStrong:1;
        unsigned int didEndStrong:1;
        unsigned int didStartLink:1;
        unsigned int didEndLink:1;
        unsigned int didStartImage:1;
        unsigned int didEndImage:1;
        unsigned int foundHTML:1;
        unsigned int foundInlineHTML:1;
        unsigned int foundCodeBlock:1;
        unsigned int foundInlineCode:1;
        unsigned int foundSoftBreak:1;
        unsigned int foundLineBreak:1;
        unsigned int didStartBlockQuote:1;
        unsigned int didEndBlockQuote:1;
        unsigned int didStartUnorderedList:1;
        unsigned int didEndUnorderedList:1;
        unsigned int didStartOrderedList:1;
        unsigned int didEndOrderedList:1;
        unsigned int didStartListItem:1;
        unsigned int didEndListItem:1;
    } _delegateFlags;
    
    CMDocument *_document;
    dispatch_queue_t _queue;
    volatile uint32_t _parsing;
}

#pragma mark - Initialization

- (instancetype)initWithDocument:(CMDocument *)document delegate:(id<CMParserDelegate>)delegate queue:(dispatch_queue_t)queue
{
    NSParameterAssert(document);
    
    if ((self = [super init])) {
        _document = document;
        _queue = queue;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Parsing

- (void)parse
{
    if (self.parsing) return;

    self.parsing = YES;
    [[_document.rootNode iterator] enumerateUsingBlock:^(CMNode *node, cmark_event_type event, BOOL *stop) {
        [self handleNode:node event:event];
        @synchronized(self) {
            if (!_parsing) *stop = YES;
        }
    }];
    self.parsing = NO;
}

- (void)abortParsing
{
    self.parsing = NO;
    if (_delegateFlags.didAbort) {
        dispatch_async(_queue, ^{
            [self.delegate parserDidAbort:self];
        });
    }
}

- (void)handleNode:(CMNode *)node event:(cmark_event_type)event {
    
}

#pragma mark - Accessors

- (BOOL)parsing
{
    return _parsing != 0;
}

- (void)setParsing:(BOOL)parsing
{
    if (parsing) {
        OSAtomicOr32Barrier(1, &_parsing);
    } else {
        OSAtomicAnd32Barrier(0, &_parsing);
    }
}

- (void)setDelegate:(id<CMParserDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateFlags.didStartDocument = [_delegate respondsToSelector:@selector(parserDidStartDocument:)];
        _delegateFlags.didEndDocument = [_delegate respondsToSelector:@selector(parserDidEndDocument:)];
        _delegateFlags.didAbort = [_delegate respondsToSelector:@selector(parserDidAbort:)];
        _delegateFlags.foundText = [_delegate respondsToSelector:@selector(parser:foundText:)];
        _delegateFlags.foundHRule = [_delegate respondsToSelector:@selector(parserFoundHRule:)];
        _delegateFlags.didStartHeader = [_delegate respondsToSelector:@selector(parser:didStartHeaderWithLevel:)];
        _delegateFlags.didEndHeader = [_delegate respondsToSelector:@selector(parser:didEndHeaderWithLevel:)];
        _delegateFlags.didStartParagraph = [_delegate respondsToSelector:@selector(parserDidStartParagraph:)];
        _delegateFlags.didEndParagraph = [_delegate respondsToSelector:@selector(parserDidEndParagraph:)];
        _delegateFlags.didStartEmphasis = [_delegate respondsToSelector:@selector(parserDidStartEmphasis:)];
        _delegateFlags.didEndEmphasis = [_delegate respondsToSelector:@selector(parserDidEndEmphasis:)];
        _delegateFlags.didStartStrong = [_delegate respondsToSelector:@selector(parserDidStartStrong:)];
        _delegateFlags.didEndStrong = [_delegate respondsToSelector:@selector(parserDidEndStrong:)];
        _delegateFlags.didStartLink = [_delegate respondsToSelector:@selector(parser:didStartLink:title:)];
        _delegateFlags.didEndLink = [_delegate respondsToSelector:@selector(parser:didEndLink:title:)];
        _delegateFlags.didStartImage = [_delegate respondsToSelector:@selector(parser:didStartImageWithURL:title:)];
        _delegateFlags.didEndImage = [_delegate respondsToSelector:@selector(parser:didEndImageWithURL:title:)];
        _delegateFlags.foundHTML = [_delegate respondsToSelector:@selector(parser:foundHTML:)];
        _delegateFlags.foundInlineHTML = [_delegate respondsToSelector:@selector(parser:foundInlineHTML:)];
        _delegateFlags.foundCodeBlock = [_delegate respondsToSelector:@selector(parser:foundCodeBlock:info:)];
        _delegateFlags.foundInlineCode = [_delegate respondsToSelector:@selector(parser:foundInlineCode:)];
        _delegateFlags.foundSoftBreak = [_delegate respondsToSelector:@selector(parserFoundSoftBreak:)];
        _delegateFlags.foundLineBreak = [_delegate respondsToSelector:@selector(parserFoundLineBreak:)];
        _delegateFlags.didStartBlockQuote = [_delegate respondsToSelector:@selector(parserDidStartBlockQuote:)];
        _delegateFlags.didEndBlockQuote = [_delegate respondsToSelector:@selector(parserDidEndBlockQuote:)];
        _delegateFlags.didStartUnorderedList = [_delegate respondsToSelector:@selector(parser:didStartUnorderedList:tight:)];
        _delegateFlags.didEndUnorderedList = [_delegate respondsToSelector:@selector(parser:didEndUnorderedList:tight:)];
        _delegateFlags.didStartOrderedList = [_delegate respondsToSelector:@selector(parser:didStartOrderedListWithStartingNumber:tight:)];
        _delegateFlags.didEndOrderedList = [_delegate respondsToSelector:@selector(parser:didEndOrderedListWithStartingNumber:tight:)];
        _delegateFlags.didStartListItem = [_delegate respondsToSelector:@selector(parserDidStartListItem:)];
        _delegateFlags.didEndListItem = [_delegate respondsToSelector:@selector(parserDidEndListItem:)];
    }
}

@end
