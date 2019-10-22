//
//  CMTextAttributes.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMTextAttributes.h"
#import "CMPlatformDefines.h"

static NSDictionary * CMDefaultTextAttributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:12.0]};
#endif
}

static NSMutableParagraphStyle* defaultHeaderParagraphStyle()
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacingBefore = 16;
    paragraphStyle.paragraphSpacing = 8;
    return paragraphStyle;
}

static NSDictionary * CMDefaultH1Attributes()
{
    NSMutableParagraphStyle* h1ParagraphStyle = defaultHeaderParagraphStyle();
    h1ParagraphStyle.paragraphSpacingBefore = 28;
    h1ParagraphStyle.paragraphSpacing = 14;
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
             NSParagraphStyleAttributeName: h1ParagraphStyle };
#else
    return @{NSFontAttributeName: [NSFont boldSystemFontOfSize:28.0],
             NSParagraphStyleAttributeName: h1ParagraphStyle };
#endif
}

static NSDictionary * CMDefaultH2Attributes()
{
    NSMutableParagraphStyle* h2ParagraphStyle = defaultHeaderParagraphStyle();
    h2ParagraphStyle.paragraphSpacingBefore = 20;
    h2ParagraphStyle.paragraphSpacing = 10;
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
             NSParagraphStyleAttributeName: h2ParagraphStyle};
#else
    return @{NSFontAttributeName: [NSFont boldSystemFontOfSize:22.0],
             NSParagraphStyleAttributeName: h2ParagraphStyle,
             };
#endif
}

static NSDictionary * CMDefaultH3Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle() };
#else
    return @{NSFontAttributeName: [NSFont boldSystemFontOfSize:16.0],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle(),
             };
#endif
}

static NSDictionary * CMDefaultH4Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle() };
#else
    return @{NSFontAttributeName: [NSFont boldSystemFontOfSize:14.0],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle(),
             };
#endif
}

static NSDictionary * CMDefaultH5Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle() };
#else
    return @{NSFontAttributeName: [NSFont boldSystemFontOfSize:12.0],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle(),
             };
#endif
}

static NSDictionary * CMDefaultH6Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle() };
#else
    return @{NSFontAttributeName: [NSFont boldSystemFontOfSize:10.0],
             NSParagraphStyleAttributeName: defaultHeaderParagraphStyle(),
             };
#endif
}

static NSDictionary * CMDefaultParagraphAttributes()
{
    NSMutableParagraphStyle* paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.paragraphSpacingBefore = 12;
    
    return @{NSParagraphStyleAttributeName: paragraphStyle};
}

static NSDictionary * CMDefaultLinkAttributes()
{
    return @{
#if TARGET_OS_IPHONE
        NSForegroundColorAttributeName: UIColor.blueColor,
#else
        NSForegroundColorAttributeName: NSColor.blueColor,
#endif
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
    };
}

static NSDictionary * CMDefaultImageParagraphAttributes()
{
    NSMutableParagraphStyle* paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.paragraphSpacingBefore = 12;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{NSParagraphStyleAttributeName: paragraphStyle};
}

#if TARGET_OS_IPHONE
static UIFont * defaultMonospaceFont()
{
    if (@available(iOS 11.0, *)) {
        CGFloat baseFontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleBody 
                                   compatibleWithTraitCollection:[UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryMedium]].pointSize;
        UIFont* baseMonospaceFont = [UIFont fontWithName:@"Menlo" size:baseFontSize] ?: [UIFont fontWithName:@"Courier" size:baseFontSize];
        return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:baseMonospaceFont];
    } else {
        // Fallback on earlier versions
        CGFloat size = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] pointSize];
        return [UIFont fontWithName:@"Menlo" size:size] ?: [UIFont fontWithName:@"Courier" size:size];
    }
}
#endif

static NSParagraphStyle * DefaultIndentedParagraphStyle()
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 30;
    style.headIndent = 30;
    return style;
}

static NSDictionary * CMDefaultCodeBlockAttributes()
{
    return @{
#if TARGET_OS_IPHONE
        NSFontAttributeName: defaultMonospaceFont(),
#else
        NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0],
#endif
        NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()
    };
}

static NSDictionary * CMDefaultInlineCodeAttributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: defaultMonospaceFont()};
#else
    return @{NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0]};
#endif
}

static NSDictionary * CMDefaultBlockQuoteAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

static NSDictionary * CMDefaultOrderedListAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

static NSDictionary * CMDefaultUnorderedListAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

static NSDictionary * CMDefaultOrderedSublistAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

static NSDictionary * CMDefaultUnorderedSublistAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

@implementation CMTextAttributes

- (instancetype)init
{
    if ((self = [super init])) {
        _textAttributes = CMDefaultTextAttributes();
        _h1Attributes = CMDefaultH1Attributes();
        _h2Attributes = CMDefaultH2Attributes();
        _h3Attributes = CMDefaultH3Attributes();
        _h4Attributes = CMDefaultH4Attributes();
        _h5Attributes = CMDefaultH5Attributes();
        _h6Attributes = CMDefaultH6Attributes();
        _paragraphAttributes = CMDefaultParagraphAttributes();
        _linkAttributes = CMDefaultLinkAttributes();
        _imageParagraphAttributes = CMDefaultImageParagraphAttributes();
        _codeBlockAttributes = CMDefaultCodeBlockAttributes();
        _inlineCodeAttributes = CMDefaultInlineCodeAttributes();
        _blockQuoteAttributes = CMDefaultBlockQuoteAttributes();
        _orderedListAttributes = CMDefaultOrderedListAttributes();
        _unorderedListAttributes = CMDefaultUnorderedListAttributes();
        _orderedSublistAttributes = CMDefaultOrderedSublistAttributes();
        _unorderedSublistAttributes = CMDefaultUnorderedSublistAttributes();
    }
    return self;
}

- (NSDictionary *)attributesForHeaderLevel:(NSInteger)level
{
    switch (level) {
        case 1: return _h1Attributes;
        case 2: return _h2Attributes;
        case 3: return _h3Attributes;
        case 4: return _h4Attributes;
        case 5: return _h5Attributes;
        default: return _h6Attributes;
    }
}

@end
