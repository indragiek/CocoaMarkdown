//
//  CMHTMLSuperscriptTransformer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHTMLSuperscriptTransformer.h"
#import "CMPlatformDefines.h"

#import "Ono.h"

#if TARGET_OS_IPHONE
#import <CoreText/CTStringAttributes.h>
#endif

@implementation CMHTMLSuperscriptTransformer {
    CGFloat _fontSizeRatio;
}

- (instancetype)init
{
    return [self initWithFontSizeRatio:0.7];
}

- (instancetype)initWithFontSizeRatio:(CGFloat)ratio
{
    if ((self = [super init])) {
        _fontSizeRatio = ratio;
    }
    return self;
}

+ (NSString *)tagName { return @"sup"; };

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    CMAssertCorrectTag(element);
    
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
    NSString *superscriptAttribute = nil;
#if TARGET_OS_IPHONE
    superscriptAttribute = (__bridge NSString *)kCTSuperscriptAttributeName;
#else
    superscriptAttribute = NSSuperscriptAttributeName;
#endif
    allAttributes[superscriptAttribute] = @1;
    CMFont *font = attributes[NSFontAttributeName];
    if (font != nil) {
        font = [CMFont fontWithDescriptor:font.fontDescriptor size:font.pointSize * _fontSizeRatio];
        allAttributes[NSFontAttributeName] = font;
    }
    
    return [[NSAttributedString alloc] initWithString:element.stringValue attributes:allAttributes];
}

@end
