//
//  CMHoedownParser.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/19/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMParser.h"

@interface CMHoedownParser : NSObject <CMParser>

/**
 *  Initializes the receiver with raw Markdown data.
 *
 *  @param data Markdown data.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithData:(NSData *)data delegate:(id<CMParserDelegate>)delegate;

/**
 *  Initializes the receiver with a Markdown string.
 *
 *  @param string Markdown string.
 *
 *  @return An initialized instance of the receiver, or `nil` if the string
 *  could not be converted to UTF8 data.
 */
- (instancetype)initWithString:(NSString *)string delegate:(id<CMParserDelegate>)delegate;

/**
 *  Initializes the receiver with the contents of a Markdown file.
 *
 *  @param path The path to the Markdown file.
 *
 *  @return An initialized instance of the receiver, or `nil` if the file could
 *  not be read.
 */
- (instancetype)initWithContentsOfFile:(NSString *)path delegate:(id<CMParserDelegate>)delegate;

@end
