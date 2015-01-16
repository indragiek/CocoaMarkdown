//
//  CMAttributeHelpers.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMAttributeHelpers.h"

CMFont * CMFontWithTraits(CMFontSymbolicTraits traits, CMFont *font)
{
    CMFontSymbolicTraits combinedTraits = font.fontDescriptor.symbolicTraits | (traits & 0xFFFF);
#if TARGET_OS_IPHONE
    UIFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:combinedTraits];
    return [UIFont fontWithDescriptor:descriptor size:font.pointSize];
#else
    NSDictionary *attributes = @{
        NSFontFamilyAttribute: font.familyName,
        NSFontTraitsAttribute: @{
            NSFontSymbolicTrait: @(combinedTraits)
        },
    };
    NSFontDescriptor *descriptor = [NSFontDescriptor fontDescriptorWithFontAttributes:attributes];
    return [NSFont fontWithDescriptor:descriptor size:font.pointSize];
#endif
}
