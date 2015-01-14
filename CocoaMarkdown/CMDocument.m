//
//  CMDocument.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMDocument.h"
#import "CMNode.h"

@implementation CMDocument

- (instancetype)initWithData:(NSData *)data
{
    NSParameterAssert(data);
    
    if ((self = [super init])) {
        cmark_node *node = cmark_parse_document((const char *)data.bytes, data.length);
        _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)path
{
    if ((self = [super init])) {
        FILE *fp = fopen(path.UTF8String, "r");
        if (fp == NULL) return nil;
        
        cmark_node *node = cmark_parse_file(fp);
        fclose(fp);
        
        _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
    }
    return self;
}

@end
