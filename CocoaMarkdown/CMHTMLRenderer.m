//
//  CMHTMLRenderer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/20/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHTMLRenderer.h"
#import "CMDocument.h"
#import "CMNode_Private.h"

@implementation CMHTMLRenderer {
    CMDocument *_document;
    CMHTMLOptions _options;
}

- (instancetype)initWithDocument:(CMDocument *)document options:(CMHTMLOptions)options
{
    if ((self = [super init])) {
        _document = document;
        _options = options;
    }
    return self;
}

- (NSString *)render
{
    char *html = cmark_render_html(_document.rootNode.node, _options);
    return [NSString stringWithUTF8String:html];
}

@end
