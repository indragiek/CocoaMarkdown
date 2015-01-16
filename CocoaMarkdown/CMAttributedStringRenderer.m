//
//  CMAttributedStringRenderer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMAttributedStringRenderer.h"
#import "CMTextAttributes.h"
#import "CMAttributeHelpers.h"
#import "CMNode.h"
#import "CMParser.h"
#import "CMAttributeRun.h"

@interface CMAttributedStringRenderer () <CMParserDelegate>
@end

@implementation CMAttributedStringRenderer {
    CMDocument *_document;
    CMTextAttributes *_attributes;
    NSMutableArray *_stack;
    NSMutableAttributedString *_buffer;
    NSDictionary *_cachedCascadedAttributes;
    NSAttributedString *_renderedAttributedString;
}

- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes
{
    if ((self = [super init])) {
        _document = document;
    }
    return self;
}

- (NSAttributedString *)render
{
    if (_renderedAttributedString == nil) {
        _stack = [[NSMutableArray alloc] init];
        _buffer = [[NSMutableAttributedString alloc] init];
        
        CMParser *parser = [[CMParser alloc] initWithDocument:_document delegate:self];
        [parser parse];
        
        _renderedAttributedString = [_buffer copy];
        _stack = nil;
        _buffer = nil;
    }
    
    return _renderedAttributedString;
}

#pragma mark - CMParserDelegate

- (void)parserDidStartDocument:(CMParser *)parser
{
    CMAttributeRun *rootRun = [[CMAttributeRun alloc] initWithAttributes:_attributes.textAttributes];
    [self pushAttributeRun:rootRun];
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
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:[self attributesForHeaderLevel:level]];
    [self pushAttributeRun:run];
}

- (void)parser:(CMParser *)parser didEndHeaderWithLevel:(NSInteger)level
{
    [self appendString:@"\n"];
    [self popAttributeRun];
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
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.emphasisAttributes fontTraits:hasExplicitFont ? 0 : CMFontTraitItalic];
    [self pushAttributeRun:run];
}

- (void)parserDidEndEmphasis:(CMParser *)parser
{
    [self popAttributeRun];
}

- (void)parserDidStartStrong:(CMParser *)parser
{
    BOOL hasExplicitFont = _attributes.strongAttributes[NSFontAttributeName] != nil;
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.strongAttributes fontTraits:hasExplicitFont ? 0 : CMFontTraitBold];
    [self pushAttributeRun:run];
}

- (void)parserDidEndStrong:(CMParser *)parse
{
    [self popAttributeRun];
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
    
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:baseAttributes];
    [self pushAttributeRun:run];
}

- (void)parser:(CMParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    [self popAttributeRun];
}

- (void)parser:(CMParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info
{
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.codeBlockAttributes];
    [self pushAttributeRun:run];
    [self appendString:[NSString stringWithFormat:@"\n\n%@\n\n", code]];
    [self popAttributeRun];
}

- (void)parser:(CMParser *)parser foundInlineCode:(NSString *)code
{
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.inlineCodeAttributes];
    [self pushAttributeRun:run];
    [self appendString:code];
    [self popAttributeRun];
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
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.blockQuoteAttributes];
    [self pushAttributeRun:run];
}

- (void)parserDidEndBlockQuote:(CMParser *)parser
{
    [self popAttributeRun];
}

- (void)parser:(CMParser *)parser didStartUnorderedListWithTightness:(BOOL)tight
{
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.unorderedListAttributes];
    [self pushAttributeRun:run];
    [self appendString:@"\n"];
}

- (void)parser:(CMParser *)parser didEndUnorderedListWithTightness:(BOOL)tight
{
    [self popAttributeRun];
}

- (void)parser:(CMParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.orderedListAttributes orderedListNumber:num];
    [self pushAttributeRun:run];
    [self appendString:@"\n"];
}

- (void)parser:(CMParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    [self popAttributeRun];
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
            CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.unorderedListItemAttributes];
            [self pushAttributeRun:run];
            break;
        }
        case CMARK_ORDERED_LIST: {
            CMAttributeRun *parentRun = _stack.lastObject;
            [self appendString:[NSString stringWithFormat:@"%ld. ", parentRun.orderedListItemNumber]];
            parentRun.orderedListItemNumber++;
            CMAttributeRun *run = [[CMAttributeRun alloc] initWithAttributes:_attributes.orderedListItemAttributes];
            [self pushAttributeRun:run];
            break;
        }
        default:
            break;
    }
}

- (void)parserDidEndListItem:(CMParser *)parser
{
    [self appendString:@"\n"];
    [self popAttributeRun];
}

#pragma mark - Private

- (NSDictionary *)attributesForHeaderLevel:(NSInteger)level
{
    switch (level) {
        case 1: return _attributes.h1Attributes;
        case 2: return _attributes.h2Attributes;
        case 3: return _attributes.h3Attributes;
        case 4: return _attributes.h4Attributes;
        case 5: return _attributes.h5Attributes;
        default: return _attributes.h6Attributes;
    }
}

- (void)pushAttributeRun:(CMAttributeRun *)run
{
    [_stack addObject:run];
    _cachedCascadedAttributes = nil;
}

- (CMAttributeRun *)popAttributeRun
{
    CMAttributeRun *run = _stack.lastObject;
    [_stack removeLastObject];
    _cachedCascadedAttributes = nil;
    return run;
}

- (void)appendLineBreakIfNotTightForNode:(CMNode *)node
{
    CMNode *grandparent = node.parent.parent;
    if (!grandparent.listTight) {
        [self appendString:@"\n"];
    }
}

- (void)appendString:(NSString *)string
{
    [_buffer appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:[self cascadedAttributes]]];
}

- (NSDictionary *)cascadedAttributes
{
    if (_stack.count == 0) {
        return nil;
    }
    
    if (_cachedCascadedAttributes == nil) {
        NSMutableDictionary *allAttributes = [[NSMutableDictionary alloc] init];
        for (CMAttributeRun *run in _stack) {
            CMFont *baseFont;
            CMFont *adjustedFont;
            if (run.fontTraits != 0 &&
                (baseFont = allAttributes[NSFontAttributeName]) &&
                (adjustedFont = CMFontWithTraits(run.fontTraits, baseFont))) {
                
                NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:run.attributes];
                attributes[NSFontAttributeName] = adjustedFont;
                [allAttributes addEntriesFromDictionary:attributes];
            } else if (run.attributes != nil) {
                [allAttributes addEntriesFromDictionary:run.attributes];
            }
        }
        _cachedCascadedAttributes = allAttributes;
    }
    return _cachedCascadedAttributes;
}

@end
