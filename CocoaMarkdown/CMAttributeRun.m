//
//  CMAttributeRun.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMAttributeRun.h"

@implementation CMAttributeRun

- (instancetype)initWithAttributes:(NSDictionary *)attributes
                        fontTraits:(CMFontSymbolicTraits)fontTraits
                 orderedListNumber:(NSInteger)orderedListNumber
{
    if ((self = [super init])) {
        _attributes = attributes;
        _fontTraits = fontTraits;
        _orderedListItemNumber = orderedListNumber;
    }
    return self;
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    return [self initWithAttributes:attributes fontTraits:0 orderedListNumber:0];
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes
                        fontTraits:(CMFontSymbolicTraits)fontTraits
{
    return [self initWithAttributes:attributes fontTraits:fontTraits orderedListNumber:0];
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes
                 orderedListNumber:(NSInteger)orderedListNumber
{
    return [self initWithAttributes:attributes fontTraits:0 orderedListNumber:orderedListNumber];
}

@end
