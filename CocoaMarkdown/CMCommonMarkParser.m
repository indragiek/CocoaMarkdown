//
//  CMCommonMarkParser.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMCommonMarkParser.h"
#import "CMCommonMarkDocument.h"
#import "CMCommonMarkIterator.h"
#import "CMCommonMarkNode.h"
#import "CMParserDelegateFlags.h"

#import <libkern/OSAtomic.h>

@interface CMCommonMarkParser ()
@property (atomic, readwrite) CMCommonMarkNode *currentNode;
@end

@implementation CMCommonMarkParser {
    CMParserDelegateFlags _delegateFlags;
    volatile uint32_t _parsing;
}
@synthesize delegate = _delegate;

#pragma mark - Initialization

- (instancetype)initWithDocument:(CMCommonMarkDocument *)document delegate:(id<CMParserDelegate>)delegate
{
    NSParameterAssert(document);
    NSParameterAssert(delegate);
    
    if ((self = [super init])) {
        _document = document;
        _delegate = delegate;
        _delegateFlags = CMParserDelegateFlagsForDelegate(_delegate);
    }
    return self;
}

#pragma mark - Parsing

- (void)parse
{
    if (_parsing) return;
    OSAtomicOr32Barrier(1, &_parsing);
    
    [[_document.rootNode iterator] enumerateUsingBlock:^(CMCommonMarkNode *node, cmark_event_type event, BOOL *stop) {
        self.currentNode = node;
        [self handleNode:node event:event];
        if (!_parsing) *stop = YES;
    }];
    
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

- (void)handleNode:(CMCommonMarkNode *)node event:(cmark_event_type)event {
    NSAssert((event == CMARK_EVENT_ENTER) || (event == CMARK_EVENT_EXIT), @"Event must be either an exit or enter event");
    
    switch (node.type) {
        case CMARK_NODE_DOCUMENT:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartDocument) {
                    [_delegate parserDidStartDocument:self];
                }
            } else if (_delegateFlags.didEndDocument) {
                [_delegate parserDidEndDocument:self];
            }
            break;
        case CMARK_NODE_TEXT:
            if (_delegateFlags.foundText) {
                [_delegate parser:self foundText:node.stringValue];
            }
            break;
        case CMARK_NODE_HRULE:
            if (_delegateFlags.foundHRule) {
                [_delegate parserFoundHRule:self];
            }
            break;
        case CMARK_NODE_HEADER:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartHeader) {
                    [_delegate parser:self didStartHeaderWithLevel:node.headerLevel];
                }
            } else if (_delegateFlags.didEndHeader) {
                [_delegate parser:self didEndHeaderWithLevel:node.headerLevel];
            }
            break;
        case CMARK_NODE_PARAGRAPH:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartParagraph) {
                    [_delegate parserDidStartParagraph:self];
                }
            } else if (_delegateFlags.didEndParagraph) {
                [_delegate parserDidEndParagraph:self];
            }
            break;
        case CMARK_NODE_EMPH:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartEmphasis) {
                    [_delegate parserDidStartEmphasis:self];
                }
            } else if (_delegateFlags.didEndEmphasis) {
                [_delegate parserDidEndEmphasis:self];
            }
            break;
        case CMARK_NODE_STRONG:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartStrong) {
                    [_delegate parserDidStartStrong:self];
                }
            } else if (_delegateFlags.didEndStrong) {
                [_delegate parserDidEndStrong:self];
            }
            break;
        case CMARK_NODE_LINK:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartLink) {
                    [_delegate parser:self didStartLinkWithURL:node.URL title:node.title];
                }
            } else if (_delegateFlags.didEndLink) {
                [_delegate parser:self didEndLinkWithURL:node.URL title:node.title];
            }
            break;
        case CMARK_NODE_IMAGE:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartImage) {
                    [_delegate parser:self didStartImageWithURL:node.URL title:node.title];
                }
            } else if (_delegateFlags.didEndImage) {
                [_delegate parser:self didEndImageWithURL:node.URL title:node.title];
            }
            break;
        case CMARK_NODE_HTML:
            if (_delegateFlags.foundHTML) {
                [_delegate parser:self foundHTML:node.stringValue];
            }
            break;
        case CMARK_NODE_INLINE_HTML:
            if (_delegateFlags.foundInlineHTML) {
                [_delegate parser:self foundInlineHTML:node.stringValue];
            }
            break;
        case CMARK_NODE_CODE_BLOCK:
            if (_delegateFlags.foundCodeBlock) {
                [_delegate parser:self foundCodeBlock:node.stringValue info:node.fencedCodeInfo];
            }
            break;
        case CMARK_NODE_CODE:
            if (_delegateFlags.foundInlineCode) {
                [_delegate parser:self foundInlineCode:node.stringValue];
            }
            break;
        case CMARK_NODE_SOFTBREAK:
            if (_delegateFlags.foundSoftBreak) {
                [_delegate parserFoundSoftBreak:self];
            }
            break;
        case CMARK_NODE_LINEBREAK:
            if (_delegateFlags.foundLineBreak) {
                [_delegate parserFoundLineBreak:self];
            }
            break;
        case CMARK_NODE_BLOCK_QUOTE:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartBlockQuote) {
                    [_delegate parserDidStartBlockQuote:self];
                }
            } else if (_delegateFlags.didEndBlockQuote) {
                [_delegate parserDidEndBlockQuote:self];
            }
            break;
        case CMARK_NODE_LIST:
            switch (node.listType) {
                case CMARK_ORDERED_LIST:
                    if (event == CMARK_EVENT_ENTER) {
                        if (_delegateFlags.didStartOrderedList) {
                            [_delegate parser:self didStartOrderedListWithStartingNumber:node.listStartingNumber tight:node.listTight];
                        }
                    } else if (_delegateFlags.didEndOrderedList) {
                        [_delegate parser:self didEndOrderedListWithStartingNumber:node.listStartingNumber tight:node.listTight];
                    }
                    break;
                case CMARK_BULLET_LIST:
                    if (event == CMARK_EVENT_ENTER) {
                        if (_delegateFlags.didStartUnorderedList) {
                            [_delegate parser:self didStartUnorderedListWithTightness:node.listTight];
                        }
                    } else if (_delegateFlags.didEndUnorderedList) {
                        [_delegate parser:self didEndUnorderedListWithTightness:node.listTight];
                    }
                    break;
                default:
                    break;
            }
            break;
        case CMARK_NODE_ITEM:
            if (event == CMARK_EVENT_ENTER) {
                if (_delegateFlags.didStartListItem) {
                    [_delegate parserDidStartListItem:self];
                }
            } else if (_delegateFlags.didEndListItem) {
                [_delegate parserDidEndListItem:self];
            }
            break;
        default:
            break;
    }
}

@end
