//
//  CMCommonMarkNode.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMCommonMarkNode.h"
#import "CMCommonMarkNode_Private.h"
#import "CMCommonMarkIterator.h"

static CMCommonMarkNode * wrap(cmark_node *node) {
    if (node == NULL) return nil;
    
    return [[CMCommonMarkNode alloc] initWithNode:node freeWhenDone:NO];
}

static NSString * str(const char *buf) {
    if (buf == NULL) return nil;
    
    return [NSString stringWithUTF8String:buf];
}

@implementation CMCommonMarkNode {
    BOOL _freeWhenDone;
}

#pragma mark - Initialization

- (instancetype)init
{
    NSAssert(NO, @"CMCommonMarkNode instance can not be created.");
    return nil;
}

- (instancetype)initWithNode:(cmark_node *)node freeWhenDone:(BOOL)free
{
    NSParameterAssert(node);
    
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

#pragma mark - NSObject

- (BOOL)isEqual:(CMCommonMarkNode *)node
{
    if (self == node) return YES;
    if (![node isMemberOfClass:self.class]) return NO;
    
    return _node == node->_node;
}

- (NSUInteger)hash
{
    return (NSUInteger)_node;
}

#pragma mark - Iteration

- (CMCommonMarkIterator *)iterator
{
    return [[CMCommonMarkIterator alloc] initWithRootNode:self];
}

#pragma mark - Tree Traversal

- (CMCommonMarkNode *)next
{
    return wrap(cmark_node_next(_node));
}

- (CMCommonMarkNode *)previous
{
    return wrap(cmark_node_previous(_node));
}

- (CMCommonMarkNode *)parent
{
    return wrap(cmark_node_parent(_node));
}

- (CMCommonMarkNode *)firstChild
{
    return wrap(cmark_node_first_child(_node));
}

- (CMCommonMarkNode *)lastChild
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

- (NSInteger)headerLevel
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

- (NSInteger)listStartingNumber
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

- (NSInteger)startLine
{
    return cmark_node_get_start_line(_node);
}

- (NSInteger)startColumn
{
    return cmark_node_get_start_column(_node);
}

- (NSInteger)endLine
{
    return cmark_node_get_start_column(_node);
}

- (NSInteger)endColumn
{
    return cmark_node_get_end_column(_node);
}

@end
