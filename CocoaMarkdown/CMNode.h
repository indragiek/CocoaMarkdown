//
//  CMNode.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cmark.h"

/**
 *  Immutable interface to a CommonMark node.
 */
@interface CMNode : NSObject

/**
 *  Pointer to the underlying node.
 */
@property (nonatomic, readonly) cmark_node *node;

/**
 *  Designated initializer.
 *
 *  @param node Pointer to the node to wrap.
 *  @param free Whether to free the underlying node when the
 *  receiver is deallocated.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithNode:(cmark_node *)node freeWhenDone:(BOOL)free;

/**
 *  The next node in the sequence, or `nil` if there is none.
 */
@property (nonatomic, readonly) CMNode *next;

/**
 *  The previous node in the sequence, or `nil` if there is none.
 */
@property (nonatomic, readonly) CMNode *previous;

/**
 *  The receiver's parent node, or `nil` if there is none.
 */
@property (nonatomic, readonly) CMNode *parent;

/**
 *  The first child node of the receiver, or `nil` if there is none.
 */
@property (nonatomic, readonly) CMNode *firstChild;

/**
 *  The last child node of the receiver, or `nil` if there is none.
 */
@property (nonatomic, readonly) CMNode *lastChild;

/**
 *  The type of the node, or `CMARK_NODE_NONE` on error.
 */
@property (nonatomic, readonly) cmark_node_type type;

/**
 *  String representation of `type`.
 */
@property (nonatomic, readonly) NSString *humanReadableType;

/**
 *  String contents of the receiver, or `nil` if there is none.
 */
@property (nonatomic, readonly) NSString *stringValue;

/**
 *  Header level of the receiver, or `0` if the receiver is not a header.
 */
@property (nonatomic, readonly) int headerLevel;

/**
 *  Info string from a fenced code block, or `nil` if there is none.
 */
@property (nonatomic, readonly) NSString *fencedCodeInfo;

/**
 *  The receiver's list type, or `CMARK_NO_LIST` if the receiver
 *  is not a list.
 */
@property (nonatomic, readonly) cmark_list_type listType;

/**
 *  The receiver's list delimeter type, or `CMARK_NO_DELIM` if the
 *  receiver is not a list.
 */
@property (nonatomic, readonly) cmark_delim_type listDelimeterType;

/**
 *  Starting number of the list, or `0` if the receiver is not
 *  an ordered list.
 */
@property (nonatomic, readonly) int listStartingNumber;

/**
 *  `YES` if the receiver is a tight list, `NO` otherwise.
 */
@property (nonatomic, readonly) BOOL listTight;

/**
 *  Link or image URL, or `nil` if there is none.
 */
@property (nonatomic, readonly) NSURL *URL;

/**
 *  Link or image title, or `nil` if there is none.
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  The line on which the receiver begins.
 */
@property (nonatomic, readonly) int startLine;

/**
 *  The column on which the receiver begins.
 */
@property (nonatomic, readonly) int startColumn;

/**
 *  The line on which the receiver ends.
 */
@property (nonatomic, readonly) int endLine;

/**
 *  The column on which the receiver ends.
 */
@property (nonatomic, readonly) int endColumn;

@end
