//
//  CMParser.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/19/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMParserDelegate;

/**
 *  Parses Markdown data.
 */
@protocol CMParser <NSObject>

/**
 *  Delegate to receive callbacks during parsing.
 */
@property (nonatomic, weak, readonly) id<CMParserDelegate> delegate;

/**
 *  Start parsing.
 */
- (void)parse;

/**
 *  Stop parsing. If implemented, `-parserDidAbort:` will be called on the delegate.
 */
- (void)abortParsing;

@end

@protocol CMParserDelegate <NSObject>
@optional
- (void)parserDidStartDocument:(id<CMParser>)parser;
- (void)parserDidEndDocument:(id<CMParser>)parser;
- (void)parserDidAbort:(id<CMParser>)parser;

- (void)parser:(id<CMParser>)parser foundText:(NSString *)text;
- (void)parserFoundHRule:(id<CMParser>)parser;

- (void)parser:(id<CMParser>)parser didStartHeaderWithLevel:(NSInteger)level;
- (void)parser:(id<CMParser>)parser didEndHeaderWithLevel:(NSInteger)level;

- (void)parserDidStartParagraph:(id<CMParser>)parser;
- (void)parserDidEndParagraph:(id<CMParser>)parser;

- (void)parserDidStartEmphasis:(id<CMParser>)parser;
- (void)parserDidEndEmphasis:(id<CMParser>)parser;

- (void)parserDidStartStrong:(id<CMParser>)parser;
- (void)parserDidEndStrong:(id<CMParser>)parser;

- (void)parser:(id<CMParser>)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title;
- (void)parser:(id<CMParser>)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title;

- (void)parser:(id<CMParser>)parser didStartImageWithURL:(NSURL *)URL title:(NSString *)title;
- (void)parser:(id<CMParser>)parser didEndImageWithURL:(NSURL *)URL title:(NSString *)title;

- (void)parser:(id<CMParser>)parser foundHTML:(NSString *)HTML;
- (void)parser:(id<CMParser>)parser foundInlineHTML:(NSString *)HTML;

- (void)parser:(id<CMParser>)parser foundCodeBlock:(NSString *)code info:(NSString *)info;
- (void)parser:(id<CMParser>)parser foundInlineCode:(NSString *)code;

- (void)parserFoundSoftBreak:(id<CMParser>)parser;
- (void)parserFoundLineBreak:(id<CMParser>)parser;

- (void)parserDidStartBlockQuote:(id<CMParser>)parser;
- (void)parserDidEndBlockQuote:(id<CMParser>)parser;

- (void)parser:(id<CMParser>)parser didStartUnorderedListWithTightness:(BOOL)tight;
- (void)parser:(id<CMParser>)parser didEndUnorderedListWithTightness:(BOOL)tight;

- (void)parser:(id<CMParser>)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight;
- (void)parser:(id<CMParser>)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight;

- (void)parserDidStartListItem:(id<CMParser>)parser;
- (void)parserDidEndListItem:(id<CMParser>)parser;
@end
