#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <CocoaMarkdown/CocoaMarkdown.h>
#import "CMCommonMarkNode_Private.h"

QuickSpecBegin(CMCommonMarkNodeSpec)

describe(@"tree traversal", ^{
    it(@"should traverse the tree", ^{
        CMCommonMarkNode *parent = [[CMCommonMarkNode alloc] initWithNode:cmark_node_new(CMARK_NODE_DOCUMENT) freeWhenDone:YES];
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:cmark_node_new(CMARK_NODE_PARAGRAPH) freeWhenDone:NO];
        CMCommonMarkNode *previous = [[CMCommonMarkNode alloc] initWithNode:cmark_node_new(CMARK_NODE_PARAGRAPH) freeWhenDone:NO];
        CMCommonMarkNode *next = [[CMCommonMarkNode alloc] initWithNode:cmark_node_new(CMARK_NODE_PARAGRAPH) freeWhenDone:NO];
        
        cmark_node_append_child(parent.node, node.node);
        cmark_node_insert_before(node.node, previous.node);
        cmark_node_insert_after(node.node, next.node);
        
        expect(node.parent).to(equal(parent));
        expect(node.next).to(equal(next));
        expect(node.previous).to(equal(previous));
        expect(parent.firstChild).to(equal(previous));
        expect(parent.lastChild).to(equal(next));
    });
});

describe(@"attributes", ^{
    it(@"should get general attributes", ^{
        cmark_node *para = cmark_node_new(CMARK_NODE_PARAGRAPH);
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:para freeWhenDone:YES];
        expect(@(node.type)).to(equal(@(CMARK_NODE_PARAGRAPH)));
        expect(node.humanReadableType).toNot(beNil());
    });
    
    it(@"should get text attributes", ^{
        cmark_node *text = cmark_node_new(CMARK_NODE_TEXT);
        cmark_node_set_literal(text, "hello world");
        
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:text freeWhenDone:YES];
        expect(node.stringValue).to(equal(@"hello world"));
    });
    
    it(@"should get header attributes", ^{
        cmark_node *header = cmark_node_new(CMARK_NODE_HEADER);
        cmark_node_set_header_level(header, 2);
        
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:header freeWhenDone:YES];
        expect(@(node.headerLevel)).to(equal(@2));
    });
    
    it(@"should get fenced code attributes", ^{
        cmark_node *code = cmark_node_new(CMARK_NODE_CODE_BLOCK);
        cmark_node_set_fence_info(code, "objective-c");
        
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:code freeWhenDone:YES];
        expect(node.fencedCodeInfo).to(equal(@"objective-c"));
    });
    
    it(@"should get list attributes", ^{
        cmark_node *list = cmark_node_new(CMARK_NODE_LIST);
        cmark_node_set_list_type(list, CMARK_ORDERED_LIST);
        cmark_node_set_list_delim(list, CMARK_PERIOD_DELIM);
        cmark_node_set_list_tight(list, 1);
        cmark_node_set_list_start(list, 2);
        
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:list freeWhenDone:YES];
        expect(@(node.listType)).to(equal(@(CMARK_ORDERED_LIST)));
        expect(@(node.listDelimeterType)).to(equal(@(CMARK_PERIOD_DELIM)));
        expect(@(node.listTight)).to(beTruthy());
        expect(@(node.listStartingNumber)).to(equal(@2));
    });
    
    it(@"should get URL attributes", ^{
        cmark_node *link = cmark_node_new(CMARK_NODE_LINK);
        cmark_node_set_url(link, "http://indragie.com");
        cmark_node_set_title(link, "indragie");
        
        CMCommonMarkNode *node = [[CMCommonMarkNode alloc] initWithNode:link freeWhenDone:YES];
        expect(node.URL).to(equal([NSURL URLWithString:@"http://indragie.com"]));
        expect(node.title).to(equal(@"indragie"));
    });
});

QuickSpecEnd
