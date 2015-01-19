#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <CocoaMarkdown/CocoaMarkdown.h>
#import "CMCommonMarkNode_Private.h"

QuickSpecBegin(CMCommonMarkIteratorSpec)

it(@"should initialize", ^{
    CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:cmark_node_new(CMARK_NODE_PARAGRAPH) freeWhenDone:YES];
    CMCommonMarkIterator *iter = [[CMCommonMarkIterator alloc] initWithRootNode:node];
    expect(iter).toNot(beNil());
});

it(@"should traverse a node tree", ^{
    CMCommonMarkNode *parent = [[CMCommonMarkNode alloc] initWithNode:cmark_node_new(CMARK_NODE_DOCUMENT) freeWhenDone:YES];
    
    cmark_node *paragraph1 = cmark_node_new(CMARK_NODE_PARAGRAPH);
    cmark_node *paragraph2 = cmark_node_new(CMARK_NODE_PARAGRAPH);
    cmark_node_append_child(parent.node, paragraph1);
    cmark_node_append_child(parent.node, paragraph2);
    
    CMCommonMarkIterator *iter = [[CMCommonMarkIterator alloc] initWithRootNode:parent];
    
    __block NSInteger nodeCount = 0;
    __block NSInteger eventBalance = 0;
    [iter enumerateUsingBlock:^(CMCommonMarkNode *node, cmark_event_type event, BOOL *stop) {
        switch (event) {
            case CMARK_EVENT_ENTER:
                eventBalance++;
                break;
            case CMARK_EVENT_EXIT:
                eventBalance--;
                nodeCount++;
                break;
            default: break;
        }
        if (nodeCount == 2) *stop = YES;
    }];
    
    expect(@(nodeCount)).to(equal(@2));
    expect(@(eventBalance)).to(equal(@1));
    
    [iter resetToNode:parent withEventType:CMARK_EVENT_ENTER];
    expect(iter.currentNode).to(equal(parent));
    expect(@(iter.currentEvent)).to(equal(@(CMARK_EVENT_ENTER)));
});

QuickSpecEnd
