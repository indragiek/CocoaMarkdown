//
//  CMHTMLStrikethroughTransformer.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMHTMLElementTransformer.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define CMColor UIColor
#define CMUnderlineStyle NSUnderlineStyle
#else
#import <Cocoa/Cocoa.h>
#define CMColor NSColor
#define CMUnderlineStyle NSInteger
#endif

/**
 Transforms HTML strikethrough elements (<s>) into attributed strings.
 */
@interface CMHTMLStrikethroughTransformer : NSObject <CMHTMLElementTransformer>

/**
 *  Initializes the receiver with the default attributes -- a single line
 *  style and a color that matches the color of the text.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)init;

/**
 *  Initializes the receiver with a custom style and color.
 *
 *  @param style Strikethrough style.
 *  @param color Strikethrough color. If `nil`, the transformer uses
 *  the color of the text if it has been specified.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithStrikethroughStyle:(CMUnderlineStyle)style color:(CMColor *)color;

@end
