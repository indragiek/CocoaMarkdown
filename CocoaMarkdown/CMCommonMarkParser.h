//
//  CMCommonMarkParser.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMCommonMarkNode;

@class CMCommonMarkDocument;
@protocol CMCommonMarkParserDelegate;

/**
 *  Not really a parser, but you can pretend it is. 
 *
 *  This class takes a `CMCommonMarkDocument` (which contains the tree for the already-parsed 
 *  Markdown data) and traverses the tree to implement `NSXMLParser`-style delegate 
 *  callbacks.
 *
 *  This is useful for implementing custom renderers.
 *
 *  @warning This class is not thread-safe and can only be accessed from a single
 *  thread at a time.
 */
@interface CMCommonMarkParser : NSObject

/**
 *  Initializes the receiver with a document.
 *
 *  @param document CommonMark document.
 *  @param delegate Delegate to receive callbacks during parsing.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMCommonMarkDocument *)document delegate:(id<CMCommonMarkParserDelegate>)delegate;

/**
 *  Document being parsed.
 */
@property (nonatomic, readonly) CMCommonMarkDocument *document;

/**
 *  Delegate to receive callbacks during parsing.
 */
@property (nonatomic, weak, readonly) id<CMCommonMarkParserDelegate> delegate;

/**
 *  Returns the node currently being parsed, or `nil` if not parsing.
 */
@property (atomic, readonly) CMCommonMarkNode *currentNode;

/**
 *  Start parsing.
 */
- (void)parse;

/**
 *  Stop parsing. If implemented, `-parserDidAbort:` will be called on the delegate.
 */
- (void)abortParsing;

@end

@protocol CMCommonMarkParserDelegate <NSObject>
@optional
- (void)parserDidStartDocument:(CMCommonMarkParser *)parser;
- (void)parserDidEndDocument:(CMCommonMarkParser *)parser;
- (void)parserDidAbort:(CMCommonMarkParser *)parser;

- (void)parser:(CMCommonMarkParser *)parser foundText:(NSString *)text;
- (void)parserFoundHRule:(CMCommonMarkParser *)parser;

- (void)parser:(CMCommonMarkParser *)parser didStartHeaderWithLevel:(NSInteger)level;
- (void)parser:(CMCommonMarkParser *)parser didEndHeaderWithLevel:(NSInteger)level;

- (void)parserDidStartParagraph:(CMCommonMarkParser *)parser;
- (void)parserDidEndParagraph:(CMCommonMarkParser *)parser;

- (void)parserDidStartEmphasis:(CMCommonMarkParser *)parser;
- (void)parserDidEndEmphasis:(CMCommonMarkParser *)parser;

- (void)parserDidStartStrong:(CMCommonMarkParser *)parser;
- (void)parserDidEndStrong:(CMCommonMarkParser *)parser;

- (void)parser:(CMCommonMarkParser *)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title;
- (void)parser:(CMCommonMarkParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title;

- (void)parser:(CMCommonMarkParser *)parser didStartImageWithURL:(NSURL *)URL title:(NSString *)title;
- (void)parser:(CMCommonMarkParser *)parser didEndImageWithURL:(NSURL *)URL title:(NSString *)title;

- (void)parser:(CMCommonMarkParser *)parser foundHTML:(NSString *)HTML;
- (void)parser:(CMCommonMarkParser *)parser foundInlineHTML:(NSString *)HTML;

- (void)parser:(CMCommonMarkParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info;
- (void)parser:(CMCommonMarkParser *)parser foundInlineCode:(NSString *)code;

- (void)parserFoundSoftBreak:(CMCommonMarkParser *)parser;
- (void)parserFoundLineBreak:(CMCommonMarkParser *)parser;

- (void)parserDidStartBlockQuote:(CMCommonMarkParser *)parser;
- (void)parserDidEndBlockQuote:(CMCommonMarkParser *)parser;

- (void)parser:(CMCommonMarkParser *)parser didStartUnorderedListWithTightness:(BOOL)tight;
- (void)parser:(CMCommonMarkParser *)parser didEndUnorderedListWithTightness:(BOOL)tight;

- (void)parser:(CMCommonMarkParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight;
- (void)parser:(CMCommonMarkParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight;

- (void)parserDidStartListItem:(CMCommonMarkParser *)parser;
- (void)parserDidEndListItem:(CMCommonMarkParser *)parser;

@end