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

#define CMFontSymbolicTraits UIFontDescriptorSymbolicTraits
#define CMFont UIFont
#define CMFontDescriptor UIFontDescriptor
#define CMFontTraitItalic UIFontDescriptorTraitItalic
#define CMFontTraitBold UIFontDescriptorTraitBold

#else
#import <Cocoa/Cocoa.h>

#define CMFontSymbolicTraits NSFontSymbolicTraits
#define CMFont NSFont
#define CMFontDescriptor NSFontDescriptor
#define CMFontTraitItalic NSFontItalicTrait
#define CMFontTraitBold NSFontBoldTrait

#endif

#endif