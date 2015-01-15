//
//  CMStringAttributes.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMStringAttributes.h"

NSDictionary * CMDefaultTextAttributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:12.0]};
#endif
}

NSDictionary * CMDefaultH1Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:24.0]};
#endif
}

NSDictionary * CMDefaultH2Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:18.0]};
#endif
}

NSDictionary * CMDefaultH3Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:14.0]};
#endif
}

NSDictionary * CMDefaultH4Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:12.0]};
#endif
}

NSDictionary * CMDefaultH5Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:10.0]};
#endif
}

NSDictionary * CMDefaultH6Attributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
#else
    return @{NSFontAttributeName: [NSFont userFontOfSize:8.0]};
#endif
}

NSDictionary * CMDefaultLinkAttributes()
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

#if TARGET_OS_IPHONE
static UIFont * MonospaceFont()
{
    CGFloat size = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] pointSize];
    return [UIFont fontWithName:@"Menlo" size:size] ?: [UIFont fontWithName:@"Courier" size:size];
}
#endif

static NSParagraphStyle * DefaultIndentedParagraphStyle()
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 30;
    style.headIndent = 30;
    return style;
}

NSDictionary * CMDefaultCodeBlockAttributes()
{
    return @{
#if TARGET_OS_IPHONE
        NSFontAttributeName: MonospaceFont(),
#else
        NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0],
#endif
        NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()
    };
}

NSDictionary * CMDefaultInlineCodeAttributes()
{
#if TARGET_OS_IPHONE
    return @{NSFontAttributeName: MonospaceFont()};
#else
    return @{NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0]};
#endif
}

NSDictionary * CMDefaultBlockQuoteAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

NSDictionary * CMDefaultOrderedListAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

NSDictionary * CMDefaultUnorderedListAttributes()
{
    return @{NSParagraphStyleAttributeName: DefaultIndentedParagraphStyle()};
}

CMFont * CMFontWithTraits(CMFontSymbolicTraits traits, CMFont *font)
{
    CMFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:font.fontDescriptor.symbolicTraits | (traits & 0xFFFF)];
    return [CMFont fontWithDescriptor:descriptor size:font.pointSize];
}
