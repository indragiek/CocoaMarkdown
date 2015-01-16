//
//  CMAttributedStringRenderer.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMDocument;
@class CMTextAttributes;
/**
 *  Renders an attributed string from a Markdown document
 */
@interface CMAttributedStringRenderer : NSObject

/**
 *  Designated initializer.
 *
 *  @param document   A Markdown document.
 *  @param attributes Attributes used to style the string.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes;

/**
 *  Renders an attributed string from the Markdown document.
 *
 *  @return An attributed string containing the contents of the Markdown document,
 *  styled using the attributes set on the receiver.
 */
- (NSAttributedString *)render;

@end
