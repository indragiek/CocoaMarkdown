//
//  CMCommonMarkParser.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMParser.h"

@class CMCommonMarkNode;
@class CMCommonMarkDocument;

/**
 *  Not really a parser, but you can pretend it is. 
 *
 *  This class takes a `CMCommonMarkDocument` (which contains the tree for the already-parsed 
 *  Markdown data) and traverses the tree to implement `NSXMLParser`-style delegate 
 *  callbacks.
 *
 *  This is useful for implementing custom renderers.
 */
@interface CMCommonMarkParser : NSObject <CMParser>

/**
 *  Initializes the receiver with a document.
 *
 *  @param document CommonMark document.
 *  @param delegate Delegate to receive callbacks during parsing.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMCommonMarkDocument *)document delegate:(id<CMParserDelegate>)delegate;

/**
 *  Document being parsed.
 */
@property (nonatomic, readonly) CMCommonMarkDocument *document;

/**
 *  Returns the node currently being parsed, or `nil` if not parsing.
 */
@property (atomic, readonly) CMCommonMarkNode *currentNode;

@end
