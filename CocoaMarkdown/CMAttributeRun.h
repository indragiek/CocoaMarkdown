//
//  CMAttributeRun.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPlatformDefines.h"

@class CMStyleAttributes;

@interface CMAttributeRun : NSObject
@property (nonatomic, readonly) CMStyleAttributes *attributes;
@property (nonatomic) NSInteger orderedListItemNumber;
@property (nonatomic, readonly) BOOL listTight;

- (instancetype)initWithAttributes:(CMStyleAttributes *)attributes
                 orderedListNumber:(NSInteger)orderedListNumber;

@end

CMAttributeRun * CMDefaultAttributeRun(CMStyleAttributes *attributes);
CMAttributeRun * CMOrderedListAttributeRun(CMStyleAttributes *attributes, NSInteger startingNumber);
