//
//  CMCommonMarkParserTestObject.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMCommonMarkParserTestObject.h"
#import <CocoaMarkdown/CocoaMarkdown.h>

@interface CMCommonMarkParserTestObject () <CMCommonMarkParserDelegate>
@end

@implementation CMCommonMarkParserTestObject {
    CMCommonMarkParser *_parser;
    NSMutableArray *_foundText;
    NSMutableArray *_didStartHeader;
    NSMutableArray *_didEndHeader;
    NSMutableArray *_didStartLink;
    NSMutableArray *_didEndLink;
    NSMutableArray *_didStartImage;
    NSMutableArray *_didEndImage;
    NSMutableArray *_foundHTML;
    NSMutableArray *_foundInlineHTML;
    NSMutableArray *_foundCodeBlock;
    NSMutableArray *_foundInlineCode;
    NSMutableArray *_didStartUnorderedList;
    NSMutableArray *_didEndUnorderedList;
    NSMutableArray *_didStartOrderedList;
    NSMutableArray *_didEndOrderedList;
}

- (instancetype)initWithDocument:(CMCommonMarkDocument *)document
{
    NSParameterAssert(document);
    if ((self = [super init])) {
        _parser = [[CMCommonMarkParser alloc] initWithDocument:document delegate:self];
        
        _foundText = [[NSMutableArray alloc] init];
        _didStartHeader = [[NSMutableArray alloc] init];
        _didEndHeader = [[NSMutableArray alloc] init];
        _didStartLink = [[NSMutableArray alloc] init];
        _didEndLink = [[NSMutableArray alloc] init];
        _didStartImage = [[NSMutableArray alloc] init];
        _didEndImage = [[NSMutableArray alloc] init];
        _foundHTML = [[NSMutableArray alloc] init];
        _foundInlineHTML = [[NSMutableArray alloc] init];
        _foundCodeBlock = [[NSMutableArray alloc] init];
        _foundInlineCode = [[NSMutableArray alloc] init];
        _didStartUnorderedList = [[NSMutableArray alloc] init];
        _didEndUnorderedList = [[NSMutableArray alloc] init];
        _didStartOrderedList = [[NSMutableArray alloc] init];
        _didEndOrderedList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parse
{
    [_parser parse];
}

#pragma mark - CMCommonMarkParserDelegate

- (void)parserDidStartDocument:(CMCommonMarkParser *)parser
{
    _didStartDocument++;
    if (_abortOnStart) {
        [parser abortParsing];
    }
}

- (void)parserDidEndDocument:(CMCommonMarkParser *)parser
{
    _didEndDocument++;
}

- (void)parserDidAbort:(CMCommonMarkParser *)parser
{
    _didAbort++;
}

- (void)parser:(CMCommonMarkParser *)parser foundText:(NSString *)text
{
    [_foundText addObject:text];
}

- (void)parserFoundHRule:(CMCommonMarkParser *)parser
{
    _foundHRule++;
}

- (void)parser:(CMCommonMarkParser *)parser didStartHeaderWithLevel:(NSInteger)level
{
    [_didStartHeader addObject:@(level)];
}

- (void)parser:(CMCommonMarkParser *)parser didEndHeaderWithLevel:(NSInteger)level
{
    [_didEndHeader addObject:@(level)];
}

- (void)parserDidStartParagraph:(CMCommonMarkParser *)parser
{
    _didStartParagraph++;
}

- (void)parserDidEndParagraph:(CMCommonMarkParser *)parser
{
    _didEndParagraph++;
}

- (void)parserDidStartEmphasis:(CMCommonMarkParser *)parser
{
    _didStartEmphasis++;
}

- (void)parserDidEndEmphasis:(CMCommonMarkParser *)parser
{
    _didEndEmphasis++;
}

- (void)parserDidStartStrong:(CMCommonMarkParser *)parser
{
    _didStartStrong++;
}

- (void)parserDidEndStrong:(CMCommonMarkParser *)parser
{
    _didEndStrong++;
}

- (void)parser:(CMCommonMarkParser *)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    NSParameterAssert(URL);
    [_didStartLink addObject:@[URL, title ?: NSNull.null]];
}

- (void)parser:(CMCommonMarkParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    NSParameterAssert(URL);
    [_didEndLink addObject:@[URL, title ?: NSNull.null]];
}

- (void)parser:(CMCommonMarkParser *)parser didStartImageWithURL:(NSURL *)URL title:(NSString *)title
{
    NSParameterAssert(URL);
    [_didStartImage addObject:@[URL, title ?: NSNull.null]];
}

- (void)parser:(CMCommonMarkParser *)parser didEndImageWithURL:(NSURL *)URL title:(NSString *)title
{
    NSParameterAssert(URL);
    [_didEndImage addObject:@[URL, title ?: NSNull.null]];
}

- (void)parser:(CMCommonMarkParser *)parser foundHTML:(NSString *)HTML
{
    NSParameterAssert(HTML);
    [_foundHTML addObject:HTML];
}

- (void)parser:(CMCommonMarkParser *)parser foundInlineHTML:(NSString *)HTML
{
    NSParameterAssert(HTML);
    [_foundInlineHTML addObject:HTML];
}

- (void)parser:(CMCommonMarkParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info
{
    NSParameterAssert(code);
    [_foundCodeBlock addObject:@[code, info ?: NSNull.null]];
}

- (void)parser:(CMCommonMarkParser *)parser foundInlineCode:(NSString *)code
{
    [_foundInlineCode addObject:code];
}

- (void)parserFoundSoftBreak:(CMCommonMarkParser *)parser
{
    _foundSoftBreak++;
}

- (void)parserFoundLineBreak:(CMCommonMarkParser *)parser
{
    _foundLineBreak++;
}

- (void)parserDidStartBlockQuote:(CMCommonMarkParser *)parser
{
    _didStartBlockQuote++;
}

- (void)parserDidEndBlockQuote:(CMCommonMarkParser *)parser
{
    _didEndBlockQuote++;
}

- (void)parser:(CMCommonMarkParser *)parser didStartUnorderedListWithTightness:(BOOL)tight
{
    [_didStartUnorderedList addObject:@(tight)];
}

- (void)parser:(CMCommonMarkParser *)parser didEndUnorderedListWithTightness:(BOOL)tight
{
    [_didEndUnorderedList addObject:@(tight)];
}

- (void)parser:(CMCommonMarkParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    [_didStartOrderedList addObject:@[@(num), @(tight)]];
}

- (void)parser:(CMCommonMarkParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    [_didEndOrderedList addObject:@[@(num), @(tight)]];
}

- (void)parserDidStartListItem:(CMCommonMarkParser *)parser
{
    _didStartListItem++;
}

- (void)parserDidEndListItem:(CMCommonMarkParser *)parser
{
    _didEndListItem++;
}

@end
