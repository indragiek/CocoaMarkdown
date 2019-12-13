//
//  CMStack.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Array backed stack.
 */
@interface CMStack<ElementType> : NSObject
@property (nonatomic, readonly) NSArray<ElementType> *objects;

- (void)push:(ElementType)object;
- (ElementType)pop;
- (ElementType)peek;
@end
