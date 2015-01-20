//
//  CMHTMLRenderer.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/20/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(long, CMHTMLOptions) {
    /** 
     * Include a `data-sourcepos` attribute on all block elements.
     */
    CMHTMLOptionsSourcePosition = (1 << 0),
    /**
     * Render `softbreak` elements as hard line breaks.
     */
    CMHTMLOptionsHardLineBreaks = (1 << 1)
};

@class CMDocument;

/**
 *  Renders HTML from a Markdown document.
 */
@interface CMHTMLRenderer : NSObject

/**
 *  Designated initializer.
 *
 *  @param document A Markdown document.
 *  @param options  Rendering options.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMDocument *)document options:(CMHTMLOptions)options;

/**
 *  Renders HTML from the Markdown document.
 *
 *  @return A string containing the HTML representation
 *  of the document.
 */
- (NSString *)render;

@end
