//
//  CMDocument.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A Markdown document conforming to the CommonMark spec.
 */
@interface CMDocument : NSObject
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)initWithString:(NSString *)string;
@end
