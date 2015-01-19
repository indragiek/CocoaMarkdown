//
//  CMCommonMarkDocument.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMCommonMarkNode;

/**
 *  A Markdown document conforming to the CommonMark spec.
 */
@interface CMCommonMarkDocument : NSObject

/**
 *  Root node of the document.
 */
@property (nonatomic, readonly) CMCommonMarkNode *rootNode;

/**
 *  Initializes the receiver with data.
 *
 *  @param data Markdown document data.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *  Initializes the receiver with data read from a file.
 *
 *  @param path The file path to read from.
 *
 *  @return An initialized instance of the receiver, or `nil` if the file
 *  could not be opened.
 */
- (instancetype)initWithContentsOfFile:(NSString *)path;

@end
