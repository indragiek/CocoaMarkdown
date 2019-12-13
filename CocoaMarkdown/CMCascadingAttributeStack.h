//
//  CMCascadingAttributeStack.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMStyleAttributes;
@class CMAttributeRun;

@interface CMCascadingAttributeStack : NSObject

@property (nonatomic, readonly) NSDictionary *cascadedAttributes;

- (void) pushAttributes:(CMStyleAttributes*)attributes;
- (void) pushOrderedListAttributes:(CMStyleAttributes*)attributes withStartingNumber:(NSInteger)startingNumber;
- (void)pop;
- (CMAttributeRun *)peek;

- (CMStyleAttributes*) attributesWithDepth:(NSUInteger)depth; // depth=0 means stack top
@end
