//
//  CMStringAttributes.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

NSDictionary * CMDefaultTextAttributes();
NSDictionary * CMDefaultH1Attributes();
NSDictionary * CMDefaultH2Attributes();
NSDictionary * CMDefaultH3Attributes();
NSDictionary * CMDefaultH4Attributes();
NSDictionary * CMDefaultH5Attributes();
NSDictionary * CMDefaultH6Attributes();
NSDictionary * CMDefaultLinkAttributes();
NSDictionary * CMDefaultCodeBlockAttributes();
NSDictionary * CMDefaultInlineCodeAttributes();
NSDictionary * CMDefaultBlockQuoteAttributes();
NSDictionary * CMDefaultOrderedListAttributes();
NSDictionary * CMDefaultUnorderedListAttributes();
