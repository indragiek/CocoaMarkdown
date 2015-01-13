//
//  CMNode.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMNode.h"
#import "CMNode_Private.h"

static CMNode * wrap(cmark_node *node) {
    return [[CMNode alloc] initWithNode:node freeWhenDone:NO];
}

static NSString * str(const char *buf) {
    if (buf == NULL) return nil;
    
    return [NSString stringWithUTF8String:buf];
}

@implementation CMNode {
    BOOL _freeWhenDone;
    cmark_node *_node;
}

#pragma mark - Initialization

- (instancetype)initWithNode:(cmark_node *)node freeWhenDone:(BOOL)free
{
    if ((self = [super init])) {
        _node = node;
        _freeWhenDone = free;
    }
    return self;
}

- (void)dealloc
{
    if (_freeWhenDone) {
        cmark_node_free(_node);
    }
}

#pragma mark - Tree Traversal

- (CMNode *)next
{
    return wrap(cmark_node_next(_node));
}

- (CMNode *)previous
{
    return wrap(cmark_node_previous(_node));
}

- (CMNode *)parent
{
    return wrap(cmark_node_parent(_node));
}

- (CMNode *)firstChild
{
    return wrap(cmark_node_first_child(_node));
}

- (CMNode *)lastChild
{
    return wrap(cmark_node_last_child(_node));
}

#pragma mark - Attributes

- (cmark_node_type)type
{
    return cmark_node_get_type(_node);
}

- (NSString *)humanReadableType
{
    return str(cmark_node_get_type_string(_node));
}

- (NSString *)stringValue
{
    return str(cmark_node_get_literal(_node));
}

- (int)headerLevel
{
    return cmark_node_get_header_level(_node);
}

- (NSString *)fencedCodeInfo
{
    return str(cmark_node_get_fence_info(_node));
}

- (cmark_list_type)listType
{
    return cmark_node_get_list_type(_node);
}

- (cmark_delim_type)listDelimeterType
{
    return cmark_node_get_list_delim(_node);
}

- (int)listStartingNumber
{
    return cmark_node_get_list_start(_node);
}

- (BOOL)listTight
{
    return (cmark_node_get_list_tight(_node) == 0) ? NO : YES;
}

- (NSURL *)URL
{
    NSString *URLString = str(cmark_node_get_url(_node));
    if (URLString != nil) {
        return [NSURL URLWithString:URLString];
    }
    return nil;
}

- (NSString *)title
{
    return str(cmark_node_get_title(_node));
}

- (int)startLine
{
    return cmark_node_get_start_line(_node);
}

- (int)startColumn
{
    return cmark_node_get_start_column(_node);
}

- (int)endLine
{
    return cmark_node_get_start_column(_node);
}

- (int)endColumn
{
    return cmark_node_get_end_column(_node);
}

@end
