//
//  CMPlatformDefines.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#ifndef CocoaMarkdown_CMPlatformDefines_h
#define CocoaMarkdown_CMPlatformDefines_h

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

#define CMColor UIColor
#define CMFontSymbolicTraits UIFontDescriptorSymbolicTraits
#define CMFont UIFont
#define CMFontDescriptor UIFontDescriptor
#define CMFontTraitsAttribute UIFontDescriptorTraitsAttribute
#define CMFontTraitItalic UIFontDescriptorTraitItalic
#define CMFontTraitBold UIFontDescriptorTraitBold
#define CMUnderlineStyle NSUnderlineStyle

typedef UIFontDescriptorAttributeName CMFontDescriptorAttributeName;
typedef UIFontDescriptorTraitKey CMFontDescriptorTraitKey;

#else
#import <Cocoa/Cocoa.h>

#define CMColor NSColor
#define CMFontSymbolicTraits NSFontSymbolicTraits
#define CMFont NSFont
#define CMFontDescriptor NSFontDescriptor
#define CMFontTraitsAttribute NSFontTraitsAttribute
#define CMFontTraitItalic NSFontItalicTrait
#define CMFontTraitBold NSFontBoldTrait
#define CMUnderlineStyle NSInteger

typedef NSFontDescriptorAttributeName CMFontDescriptorAttributeName;
typedef NSFontDescriptorTraitKey CMFontDescriptorTraitKey;

#endif

#endif
