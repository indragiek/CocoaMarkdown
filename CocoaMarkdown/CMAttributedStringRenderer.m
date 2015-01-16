//
//  CMAttributedStringRenderer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMAttributedStringRenderer.h"
#import "CMTextAttributes.h"
#import "CMCascadingAttributeStack.h"
#import "CMNode.h"
#import "CMParser.h"
#import "CMAttributeRun.h"

@interface CMAttributedStringRenderer () <CMParserDelegate>
@end

@implementation CMAttributedStringRenderer {
    CMDocument *_document;
    CMTextAttributes *_attributes;
    CMCascadingAttributeStack *_stack;
    NSMutableAttributedString *_buffer;
    NSAttributedString *_attributedString;
}

- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes
{
    if ((self = [super init])) {
        _document = document;
        _attributes = attributes;
    }
    return self;
}

- (NSAttributedString *)render
{
    if (_attributedString == nil) {
        _stack = [[CMCascadingAttributeStack alloc] init];
        _buffer = [[NSMutableAttributedString alloc] init];
        
        CMParser *parser = [[CMParser alloc] initWithDocument:_document delegate:self];
        [parser parse];
        
        _attributedString = [_buffer copy];
        _stack = nil;
        _buffer = nil;
    }
    
    return _attributedString;
}

#pragma mark - CMParserDelegate

- (void)parserDidStartDocument:(CMParser *)parser
{
    [_stack push:CMDefaultAttributeRun(_attributes.textAttributes)];
}

- (void)parserDidEndDocument:(CMParser *)parser
{
    CFStringTrimWhitespace((__bridge CFMutableStringRef)_buffer.mutableString);
}

- (void)parser:(CMParser *)parser foundText:(NSString *)text
{
    [self appendString:text];
}

- (void)parser:(CMParser *)parser didStartHeaderWithLevel:(NSInteger)level
{
    [_stack push:CMDefaultAttributeRun([_attributes attributesForHeaderLevel:level])];
}

- (void)parser:(CMParser *)parser didEndHeaderWithLevel:(NSInteger)level
{
    [self appendString:@"\n"];
    [_stack pop];
}

- (void)parserDidStartParagraph:(CMParser *)parser
{
    [self appendLineBreakIfNotTightForNode:parser.currentNode];
}

- (void)parserDidEndParagraph:(CMParser *)parser
{
    [self appendLineBreakIfNotTightForNode:parser.currentNode];
}

- (void)parserDidStartEmphasis:(CMParser *)parser
{
    BOOL hasExplicitFont = _attributes.emphasisAttributes[NSFontAttributeName] != nil;
    [_stack push:CMTraitAttributeRun(_attributes.emphasisAttributes, hasExplicitFont ? 0 : CMFontTraitItalic)];
}

- (void)parserDidEndEmphasis:(CMParser *)parser
{
    [_stack pop];
}

- (void)parserDidStartStrong:(CMParser *)parser
{
    BOOL hasExplicitFont = _attributes.strongAttributes[NSFontAttributeName] != nil;
    [_stack push:CMTraitAttributeRun(_attributes.strongAttributes, hasExplicitFont ? 0 : CMFontTraitBold)];
}

- (void)parserDidEndStrong:(CMParser *)parse
{
    [_stack pop];
}

- (void)parser:(CMParser *)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    NSMutableDictionary *baseAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:URL, NSLinkAttributeName, nil];
#if !TARGET_OS_IPHONE
    if (title != nil) {
        baseAttributes[NSToolTipAttributeName] = title;
    }
#endif
    [baseAttributes addEntriesFromDictionary:_attributes.linkAttributes];
    [_stack push:CMDefaultAttributeRun(baseAttributes)];
}

- (void)parser:(CMParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    [_stack pop];
}

- (void)parser:(CMParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info
{
    [_stack push:CMDefaultAttributeRun(_attributes.codeBlockAttributes)];
    [self appendString:[NSString stringWithFormat:@"\n\n%@\n\n", code]];
    [_stack pop];
}

- (void)parser:(CMParser *)parser foundInlineCode:(NSString *)code
{
    [_stack push:CMDefaultAttributeRun(_attributes.inlineCodeAttributes)];
    [self appendString:code];
    [_stack pop];
}

- (void)parserFoundSoftBreak:(CMParser *)parser
{
    [self appendString:@"\n"];
}

- (void)parserFoundLineBreak:(CMParser *)parser
{
    [self appendString:@"\n"];
}

- (void)parserDidStartBlockQuote:(CMParser *)parser
{
    [_stack push:CMDefaultAttributeRun(_attributes.blockQuoteAttributes)];
}

- (void)parserDidEndBlockQuote:(CMParser *)parser
{
    [_stack pop];
}

- (void)parser:(CMParser *)parser didStartUnorderedListWithTightness:(BOOL)tight
{
    [_stack push:CMDefaultAttributeRun(_attributes.unorderedListAttributes)];
    [self appendString:@"\n"];
}

- (void)parser:(CMParser *)parser didEndUnorderedListWithTightness:(BOOL)tight
{
    [_stack pop];
}

- (void)parser:(CMParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    [_stack push:CMOrderedListAttributeRun(_attributes.orderedListAttributes, num)];
    [self appendString:@"\n"];
}

- (void)parser:(CMParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    [_stack pop];
}

- (void)parserDidStartListItem:(CMParser *)parser
{
    CMNode *node = parser.currentNode.parent;
    switch (node.listType) {
        case CMARK_NO_LIST:
            NSAssert(NO, @"Parent node of list item must be a list");
            break;
        case CMARK_BULLET_LIST: {
            [self appendString:@"\u2022 "];
            [_stack push:CMDefaultAttributeRun(_attributes.unorderedListItemAttributes)];
            break;
        }
        case CMARK_ORDERED_LIST: {
            CMAttributeRun *parentRun = [_stack peek];
            [self appendString:[NSString stringWithFormat:@"%ld. ", parentRun.orderedListItemNumber]];
            parentRun.orderedListItemNumber++;
            [_stack push:CMDefaultAttributeRun(_attributes.orderedListItemAttributes)];
            break;
        }
        default:
            break;
    }
}

- (void)parserDidEndListItem:(CMParser *)parser
{
    [self appendString:@"\n"];
    [_stack pop];
}

#pragma mark - Private

- (void)appendLineBreakIfNotTightForNode:(CMNode *)node
{
    CMNode *grandparent = node.parent.parent;
    if (!grandparent.listTight) {
        [self appendString:@"\n"];
    }
}

- (void)appendString:(NSString *)string
{
    [_buffer appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:_stack.cascadedAttributes]];
}

@end
