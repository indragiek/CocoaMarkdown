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
    NSParameterAssert(delegate);
    
    if ((self = [super init])) {
        _document = document;
        _queue = queue ?: dispatch_get_main_queue();
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
        _currentNode = node;
        [self handleNode:node event:event];
        if (self.parsing) *stop = YES;
    }];
    self.parsing = NO;
}

- (void)abortParsing
{
    if (!self.parsing) return;
    
    self.parsing = NO;
    if (_delegateFlags.didAbort) {
        dispatch_async(_queue, ^{
            [_delegate parserDidAbort:self];
        });
    }
}

- (void)handleNode:(CMNode *)node event:(cmark_event_type)event {
    NSAssert((event == CMARK_EVENT_ENTER) || (event == CMARK_EVENT_EXIT), @"Event must be either an exit or enter event");
    
    switch (node.type) {
        case CMARK_NODE_DOCUMENT:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartDocument) {
                    [_delegate parserDidStartDocument:self];
                }
            } else if (_delegateFlags.didEndDocument) {
                dispatch_async(_queue, ^{
                    [_delegate parserDidEndDocument:self];
                });
            }
            break;
        case CMARK_NODE_TEXT:
            if (_delegateFlags.foundText) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self foundText:node.stringValue];
                });
            }
            break;
        case CMARK_NODE_HRULE:
            if (_delegateFlags.foundHRule) {
                dispatch_async(_queue, ^{
                    [_delegate parserFoundHRule:self];
                });
            }
            break;
        case CMARK_NODE_HEADER:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartHeader) {
                    dispatch_async(_queue, ^{
                        [_delegate parser:self didStartHeaderWithLevel:node.headerLevel];
                    });
                }
            } else if (_delegateFlags.didEndHeader) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self didEndHeaderWithLevel:node.headerLevel];
                });
            }
            break;
        case CMARK_NODE_PARAGRAPH:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartParagraph) {
                    dispatch_async(_queue, ^{
                        [_delegate parserDidStartParagraph:self];
                    });
                }
            } else if (_delegateFlags.didEndParagraph) {
                dispatch_async(_queue, ^{
                    [_delegate parserDidEndParagraph:self];
                });
            }
            break;
        case CMARK_NODE_EMPH:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartEmphasis) {
                    dispatch_async(_queue, ^{
                        [_delegate parserDidStartEmphasis:self];
                    });
                }
            } else if (_delegateFlags.didEndEmphasis) {
                dispatch_async(_queue, ^{
                    [_delegate parserDidEndEmphasis:self];
                });
            }
            break;
        case CMARK_NODE_STRONG:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartStrong) {
                    dispatch_async(_queue, ^{
                        [_delegate parserDidStartStrong:self];
                    });
                }
            } else if (_delegateFlags.didEndStrong) {
                dispatch_async(_queue, ^{
                    [_delegate parserDidEndStrong:self];
                });
            }
            break;
        case CMARK_NODE_LINK:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartLink) {
                    dispatch_async(_queue, ^{
                        [_delegate parser:self didStartLinkWithURL:node.URL title:node.title];
                    });
                }
            } else if (_delegateFlags.didEndLink) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self didEndLinkWithURL:node.URL title:node.title];
                });
            }
            break;
        case CMARK_NODE_IMAGE:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartImage) {
                    dispatch_async(_queue, ^{
                        [_delegate parser:self didStartImageWithURL:node.URL title:node.title];
                    });
                } else if (_delegateFlags.didEndImage) {
                    dispatch_async(_queue, ^{
                        [_delegate parser:self didEndImageWithURL:node.URL title:node.title];
                    });
                }
            }
            break;
        case CMARK_NODE_HTML:
            if (_delegateFlags.foundHTML) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self foundHTML:node.stringValue];
                });
            }
            break;
        case CMARK_NODE_INLINE_HTML:
            if (_delegateFlags.foundInlineHTML) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self foundInlineHTML:node.stringValue];
                });
            }
            break;
        case CMARK_NODE_CODE_BLOCK:
            if (_delegateFlags.foundCodeBlock) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self foundCodeBlock:node.stringValue info:node.fencedCodeInfo];
                });
            }
            break;
        case CMARK_NODE_CODE:
            if (_delegateFlags.foundInlineCode) {
                dispatch_async(_queue, ^{
                    [_delegate parser:self foundInlineCode:node.stringValue];
                });
            }
            break;
        case CMARK_NODE_SOFTBREAK:
            if (_delegateFlags.foundSoftBreak) {
                dispatch_async(_queue, ^{
                    [_delegate parserFoundSoftBreak:self];
                });
            }
            break;
        case CMARK_NODE_LINEBREAK:
            if (_delegateFlags.foundLineBreak) {
                dispatch_async(_queue, ^{
                    [_delegate parserFoundLineBreak:self];
                });
            }
            break;
        case CMARK_NODE_BLOCK_QUOTE:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartBlockQuote) {
                    dispatch_async(_queue, ^{
                        [_delegate parserDidStartBlockQuote:self];
                    });
                }
            } else if (_delegateFlags.didEndBlockQuote) {
                dispatch_async(_queue, ^{
                    [_delegate parserDidEndBlockQuote:self];
                });
            }
            break;
        case CMARK_NODE_LIST:
            switch (node.listType) {
                case CMARK_ORDERED_LIST:
                    if (event == CMARK_EVENT_ENTER) {
                        if (_delegateFlags.didStartOrderedList) {
                            dispatch_async(_queue, ^{
                                [_delegate parser:self didStartOrderedListWithStartingNumber:node.listStartingNumber tight:node.listTight];
                            });
                        }
                    } else if (_delegateFlags.didEndOrderedList) {
                        dispatch_async(_queue, ^{
                            [_delegate parser:self didEndOrderedListWithStartingNumber:node.listStartingNumber tight:node.listTight];
                        });
                    }
                    break;
                case CMARK_BULLET_LIST:
                    if (event == CMARK_EVENT_ENTER) {
                        if (_delegateFlags.didStartUnorderedList) {
                            dispatch_async(_queue, ^{
                                [_delegate parser:self didStartUnorderedListWithTightness:node.listTight];
                            });
                        }
                    } else if (_delegateFlags.didEndUnorderedList) {
                        dispatch_async(_queue, ^{
                            [_delegate parser:self didEndUnorderedListWithTightness:node.listTight];
                        });
                    }
                    break;
                default:
                    break;
            }
            break;
        case CMARK_NODE_ITEM:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartListItem) {
                    dispatch_async(_queue, ^{
                        [_delegate parserDidStartListItem:self];
                    });
                }
            } else if (_delegateFlags.didEndListItem) {
                dispatch_async(_queue, ^{
                    [_delegate parserDidEndListItem:self];
                });
            }
            break;
        default:
            break;
    }
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
        _delegateFlags.didStartLink = [_delegate respondsToSelector:@selector(parser:didStartLinkWithURL:title:)];
        _delegateFlags.didEndLink = [_delegate respondsToSelector:@selector(parser:didEndLinkWithURL:title:)];
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
        _delegateFlags.didStartUnorderedList = [_delegate respondsToSelector:@selector(parser:didStartUnorderedListWithTightness:)];
        _delegateFlags.didEndUnorderedList = [_delegate respondsToSelector:@selector(parser:didEndUnorderedListWithTightness:)];
        _delegateFlags.didStartOrderedList = [_delegate respondsToSelector:@selector(parser:didStartOrderedListWithStartingNumber:tight:)];
        _delegateFlags.didEndOrderedList = [_delegate respondsToSelector:@selector(parser:didEndOrderedListWithStartingNumber:tight:)];
        _delegateFlags.didStartListItem = [_delegate respondsToSelector:@selector(parserDidStartListItem:)];
        _delegateFlags.didEndListItem = [_delegate respondsToSelector:@selector(parserDidEndListItem:)];
    }
}

@end
