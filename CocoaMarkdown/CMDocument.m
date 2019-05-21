//
//  CMDocument.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMDocument_Private.h"
#import "CMNode_Private.h"

@implementation CMDocument

- (instancetype)initWithString:(NSString *)string options:(CMDocumentOptions)options
{
    if (string != nil) {
        if ((self = [super init])) {
            const char* utf8String = string.UTF8String;
            cmark_node *node = cmark_parse_document(utf8String, strlen(utf8String), options);
            if (node == NULL) return nil;
            
            _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
            _options = options;
        }
    } else {
        self = nil;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data options:(CMDocumentOptions)options
{
    NSParameterAssert(data);
    
    if ((self = [super init])) {
        cmark_node *node = cmark_parse_document((const char *)data.bytes, data.length, options);
        if (node == NULL) return nil;
        
        _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
        _options = options;
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)path options:(CMDocumentOptions)options
{
    if ((self = [super init])) {
        FILE *fp = fopen(path.UTF8String, "r");
        if (fp == NULL) return nil;
        
        cmark_node *node = cmark_parse_file(fp, options);
        fclose(fp);
        if (node == NULL) return nil;
        
        _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
        _options = options;
        
        _linksBaseURL = [NSURL fileURLWithPath:path.stringByDeletingLastPathComponent];
    }
    return self;
}

- (NSURL*) targetURLForNode:(CMNode *)node
{
    NSURL* nodeTargetUrl = node.URL;
    if ((nodeTargetUrl.scheme == nil) && (_linksBaseURL != nil))
    {
        // If the node URL doesn't have a scheme, consider it relative to the base URL
        nodeTargetUrl = [NSURL URLWithString:node.URLString relativeToURL:_linksBaseURL].absoluteURL;
    }
    return nodeTargetUrl;
}

@end
