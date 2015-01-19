//
//  CMCommonMarkIterator.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMCommonMarkIterator.h"
#import "CMCommonMarkNode_Private.h"

@implementation CMCommonMarkIterator {
    cmark_iter *_iter;
}

#pragma mark - Initialization

- (instancetype)initWithRootNode:(CMCommonMarkNode *)rootNode
{
    NSParameterAssert(rootNode);
    
    if ((self = [super init])) {
        _iter = cmark_iter_new(rootNode.node);
        if (_iter == NULL) return nil;
    }
    return self;
}

- (void)dealloc
{
    cmark_iter_free(_iter);
}

#pragma mark - Accessors

- (CMCommonMarkNode *)currentNode
{
    return [[CMCommonMarkNode alloc] initWithNode:cmark_iter_get_node(_iter) freeWhenDone:NO];
}

- (cmark_event_type)currentEvent
{
    return cmark_iter_get_event_type(_iter);
}

#pragma mark - Iteration

- (void)enumerateUsingBlock:(void (^)(CMCommonMarkNode *node, cmark_event_type event, BOOL *stop))block
{
    NSParameterAssert(block);
    
    cmark_event_type event;
    BOOL stop = NO;
    
    while ((event = cmark_iter_next(_iter)) != CMARK_EVENT_DONE) {
        CMCommonMarkNode *currentNode = [[CMCommonMarkNode alloc] initWithNode:cmark_iter_get_node(_iter) freeWhenDone:NO];
        block(currentNode, event, &stop);
        if (stop) break;
    }
}

- (void)resetToNode:(CMCommonMarkNode *)node withEventType:(cmark_event_type)eventType
{
    cmark_iter_reset(_iter, node.node, eventType);
}

@end
