//
//  CMAttributeRun.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMAttributeRun.h"

CMAttributeRun * CMDefaultAttributeRun(CMStyleAttributes *attributes)
{
    return [[CMAttributeRun alloc] initWithAttributes:attributes orderedListNumber:0];
}

CMAttributeRun * CMOrderedListAttributeRun(CMStyleAttributes *attributes, NSInteger startingNumber)
{
    return [[CMAttributeRun alloc] initWithAttributes:attributes orderedListNumber:startingNumber];
}

@implementation CMAttributeRun

- (instancetype)initWithAttributes:(CMStyleAttributes *)attributes
                 orderedListNumber:(NSInteger)orderedListNumber
{
    if ((self = [super init])) {
        _attributes = attributes;
        _orderedListItemNumber = orderedListNumber;
    }
    return self;
}

@end
