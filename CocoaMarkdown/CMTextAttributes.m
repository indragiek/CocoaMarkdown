//
//  CMTextAttributes.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMTextAttributes.h"
#import "CMPlatformDefines.h"

@interface CMStyleAttributes ()

- (instancetype) initWithStringAttributes:(NSDictionary<NSAttributedStringKey, id>*) textAttributes;
- (instancetype) initWithStringAttributes:(NSDictionary<NSAttributedStringKey, id>*) textAttributes paragraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)paragraphStyleAttributes;
- (instancetype) initWithParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)paragraphStyleAttributes;
- (instancetype) initWithFontSymbolicTraits:(CMFontSymbolicTraits)fontSymbolicTraits;

@end

static CMStyleAttributes * CMDefaultBaseTextAttributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
#else
    stringAttributes = @{NSFontAttributeName: [NSFont userFontOfSize:12.0]};
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes];
}

static NSDictionary<CMParagraphStyleAttributeName, id> * defaultHeaderParagraphStyleAttributes()
{
    return @{ CMParagraphStyleAttributeParagraphSpacingBefore: @16,
              CMParagraphStyleAttributeParagraphSpacing: @8 };
}

static CMStyleAttributes * CMDefaultH1Attributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1] };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:28.0] };
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:@{ CMParagraphStyleAttributeParagraphSpacingBefore: @28,
                                                                  CMParagraphStyleAttributeParagraphSpacing: @14 }];
}

static CMStyleAttributes * CMDefaultH2Attributes()
{
    NSDictionary* stringAttributes;
    #if TARGET_OS_IPHONE
        stringAttributes = @{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2] };
    #else
        stringAttributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:22.0] };
    #endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:@{ CMParagraphStyleAttributeParagraphSpacingBefore: @20,
                                                                  CMParagraphStyleAttributeParagraphSpacing: @10 }];
}

static CMStyleAttributes * CMDefaultH3Attributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3] };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:16.0] };
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:defaultHeaderParagraphStyleAttributes()];
}

static CMStyleAttributes * CMDefaultH4Attributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:14.0] };
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:defaultHeaderParagraphStyleAttributes()];
}

static CMStyleAttributes * CMDefaultH5Attributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:12.0] };
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:defaultHeaderParagraphStyleAttributes()];
}

static CMStyleAttributes * CMDefaultH6Attributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:10.0] };
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:defaultHeaderParagraphStyleAttributes()];
}

static CMStyleAttributes * CMDefaultParagraphAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:@{ CMParagraphStyleAttributeParagraphSpacingBefore: @12 }];
}

static CMStyleAttributes * CMDefaultLinkAttributes()
{
    return [[CMStyleAttributes alloc] initWithStringAttributes:@{ NSForegroundColorAttributeName: CMColor.blueColor,
                                                                  NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) }];
}

static CMStyleAttributes * CMDefaultImageParagraphAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:@{ CMParagraphStyleAttributeParagraphSpacingBefore: @12,
                                                                          CMParagraphStyleAttributeAlignment: @(NSTextAlignmentCenter) }];
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

static CGFloat defaultIndentationStep = 30.0;

static CMStyleAttributes * CMDefaultCodeBlockAttributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: defaultMonospaceFont(), };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0] };
#endif

    NSDictionary* paragraphStyleAttributes = @{ CMParagraphStyleAttributeParagraphSpacingBefore: @12.0,
                                                CMParagraphStyleAttributeFirstLineHeadExtraIndent: @(defaultIndentationStep),
                                                CMParagraphStyleAttributeHeadExtraIndent: @(defaultIndentationStep) };
    
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes 
                                      paragraphStyleAttributes:paragraphStyleAttributes];
}

static CMStyleAttributes * CMDefaultInlineCodeAttributes()
{
    NSDictionary* stringAttributes;
#if TARGET_OS_IPHONE
    stringAttributes = @{ NSFontAttributeName: defaultMonospaceFont(), };
#else
    stringAttributes = @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0] };
#endif
    return [[CMStyleAttributes alloc] initWithStringAttributes:stringAttributes];
}

static  CMStyleAttributes *  CMDefaultBlockQuoteAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:@{ CMParagraphStyleAttributeFirstLineHeadExtraIndent: @(defaultIndentationStep),
                                                                          CMParagraphStyleAttributeHeadExtraIndent: @(defaultIndentationStep) }];
}

static CGFloat itemLabelIndent = 20.0;

static NSDictionary<CMParagraphStyleAttributeName, id> * DefaultListParagraphStyleAttributes()
{
    return @{ CMParagraphStyleAttributeFirstLineHeadExtraIndent: @(defaultIndentationStep + itemLabelIndent),
              CMParagraphStyleAttributeHeadExtraIndent: @(defaultIndentationStep + itemLabelIndent),
              CMParagraphStyleAttributeListItemLabelIndent: @(itemLabelIndent),
              CMParagraphStyleAttributeListItemBulletString: @"●",
              CMParagraphStyleAttributeListItemNumberFormat: @"%ld.",
    };
}

static  CMStyleAttributes *  CMDefaultOrderedListAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:DefaultListParagraphStyleAttributes()];
}

static  CMStyleAttributes *  CMDefaultUnorderedListAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:DefaultListParagraphStyleAttributes()];
}

static NSDictionary<CMParagraphStyleAttributeName, id> * DefaultSublistParagraphStyleAttributes()
{
    return @{ CMParagraphStyleAttributeFirstLineHeadExtraIndent: @(itemLabelIndent), // Align label with parent list content
              CMParagraphStyleAttributeHeadExtraIndent: @(itemLabelIndent),
              CMParagraphStyleAttributeListItemLabelIndent: @(itemLabelIndent),
              CMParagraphStyleAttributeListItemBulletString: @"○",
              CMParagraphStyleAttributeListItemNumberFormat: @"%ld.",
    };
}

static  CMStyleAttributes *  CMDefaultOrderedSublistAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:DefaultSublistParagraphStyleAttributes()];
}

static  CMStyleAttributes *  CMDefaultUnorderedSublistAttributes()
{
    return [[CMStyleAttributes alloc] initWithParagraphStyleAttributes:DefaultSublistParagraphStyleAttributes()];
}

@implementation CMTextAttributes

- (instancetype)init
{
    if ((self = [super init])) {
        _baseTextAttributes = CMDefaultBaseTextAttributes();
        _h1Attributes = CMDefaultH1Attributes();
        _h2Attributes = CMDefaultH2Attributes();
        _h3Attributes = CMDefaultH3Attributes();
        _h4Attributes = CMDefaultH4Attributes();
        _h5Attributes = CMDefaultH5Attributes();
        _h6Attributes = CMDefaultH6Attributes();
        _paragraphAttributes = CMDefaultParagraphAttributes();
        
        _emphasisAttributes = [[CMStyleAttributes alloc] initWithFontSymbolicTraits:CMFontTraitItalic];
        _strongAttributes = [[CMStyleAttributes alloc] initWithFontSymbolicTraits:CMFontTraitBold];
        
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

- (void) updateAttributesForElementKinds:(CMElementKind)elementKinds usingBlock:(void(^)(CMStyleAttributes * styleAttributes))block
{
    if ((elementKinds & CMElementKindText) != 0) {
        block(_baseTextAttributes);
    }
    if ((elementKinds & CMElementKindHeader1) != 0) {
        block(_h1Attributes);
    }
    if ((elementKinds & CMElementKindHeader2) != 0) {
        block(_h2Attributes);
    }
    if ((elementKinds & CMElementKindHeader3) != 0) {
        block(_h3Attributes);
    }
    if ((elementKinds & CMElementKindHeader4) != 0) {
        block(_h4Attributes);
    }
    if ((elementKinds & CMElementKindHeader5) != 0) {
        block(_h5Attributes);
    }
    if ((elementKinds & CMElementKindHeader6) != 0) {
        block(_h6Attributes);
    }
    if ((elementKinds & CMElementKindParagraph) != 0) {
        block(_paragraphAttributes);
    }
    if ((elementKinds & CMElementKindLink) != 0) {
        block(_linkAttributes);
    }
    if ((elementKinds & CMElementKindImageParagraph) != 0) {
        block(_imageParagraphAttributes);
    }
    if ((elementKinds & CMElementKindCodeBlock) != 0) {
        block(_codeBlockAttributes);
    }
    if ((elementKinds & CMElementKindInlineCode) != 0) {
        block(_inlineCodeAttributes);
    }
    if ((elementKinds & CMElementKindBlockQuote) != 0) {
        block(_blockQuoteAttributes);
    }
    if ((elementKinds & CMElementKindOrderedList) != 0) {
        block(_orderedListAttributes);
    }
    if ((elementKinds & CMElementKindOrderedSublist) != 0) {
        block(_orderedSublistAttributes);
    }
    if ((elementKinds & CMElementKindOrderedListItem) != 0) {
        block(_orderedListItemAttributes);
    }
    if ((elementKinds & CMElementKindUnorderedList) != 0) {
        block(_unorderedListAttributes);
    }
    if ((elementKinds & CMElementKindUnorderedSublist) != 0) {
        block(_unorderedSublistAttributes);
    }
    if ((elementKinds & CMElementKindUnorderedListItem) != 0) {
        block(_unorderedListItemAttributes);
    }
}

- (void) addStringAttributes:(NSDictionary<NSAttributedStringKey, id>*)attributes forElementWithKinds:(CMElementKind)elementKinds
{
    [self updateAttributesForElementKinds:elementKinds usingBlock:^(CMStyleAttributes *styleAttributes) {
        [styleAttributes.stringAttributes addEntriesFromDictionary:attributes];
    }];
}

- (void) addFontAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)fontAttributes forElementWithKinds:(CMElementKind)elementKinds
{
    [self updateAttributesForElementKinds:elementKinds usingBlock:^(CMStyleAttributes *styleAttributes) {
        [styleAttributes.fontAttributes addEntriesFromDictionary:fontAttributes];
    }];
}

- (void) setFontTraits:(NSDictionary<CMFontDescriptorTraitKey, id>*)fontTraits forElementWithKinds:(CMElementKind)elementKinds
{
    [self updateAttributesForElementKinds:elementKinds usingBlock:^(CMStyleAttributes *styleAttributes) {
        styleAttributes.fontAttributes[CMFontTraitsAttribute] = fontTraits;
    }];
}

- (void) addParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)attributes forElementWithKinds:(CMElementKind)elementKinds
{
    [self updateAttributesForElementKinds:elementKinds usingBlock:^(CMStyleAttributes *styleAttributes) {
        [styleAttributes.paragraphStyleAttributes addEntriesFromDictionary:attributes];
    }];
}

- (CMStyleAttributes *)attributesForHeaderLevel:(NSInteger)level
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


@implementation CMStyleAttributes

- (instancetype) init
{
    self = [super init];
    if (self != nil) {
        _stringAttributes = [NSMutableDictionary new];
        _fontAttributes = [NSMutableDictionary new];
        _paragraphStyleAttributes =[NSMutableDictionary new];
    }
    return self;
}

- (instancetype) initWithStringAttributes:(NSDictionary<NSAttributedStringKey,id> *)stringAttributes
{
    self = [self init];
    if (self != nil) {
        [_stringAttributes addEntriesFromDictionary:stringAttributes];
    }
    return self;
}

- (instancetype) initWithParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)paragraphStyleAttributes
{
    self = [self init];
    if (self != nil) {
        [_paragraphStyleAttributes addEntriesFromDictionary:paragraphStyleAttributes];
    }
    return self;
}

- (instancetype) initWithStringAttributes:(NSDictionary<NSAttributedStringKey, id>*)stringAttributes
                 paragraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)paragraphStyleAttributes
{
    self = [self init];
    if (self != nil) {
        [_stringAttributes addEntriesFromDictionary:stringAttributes];
        [_paragraphStyleAttributes addEntriesFromDictionary:paragraphStyleAttributes];
    }
    return self;    
}

- (instancetype) initWithFontSymbolicTraits:(CMFontSymbolicTraits)fontSymbolicTraits
{
    self = [self init];
    if (self != nil) {
        [self setFontSymbolicTraits:fontSymbolicTraits];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    CMStyleAttributes * copiedAttributes = [CMStyleAttributes new];
    [copiedAttributes.stringAttributes addEntriesFromDictionary:_stringAttributes];
    [copiedAttributes.fontAttributes addEntriesFromDictionary:_fontAttributes];
    [copiedAttributes.paragraphStyleAttributes addEntriesFromDictionary:_paragraphStyleAttributes];
    return copiedAttributes;
}

- (void) setFontSymbolicTraits:(CMFontSymbolicTraits)fontSymbolicTraits
{
#if TARGET_OS_IPHONE
    NSDictionary<UIFontDescriptorTraitKey, id> * currentFontTraits = _fontAttributes[UIFontDescriptorTraitsAttribute];
    if (currentFontTraits == nil) {
        _fontAttributes[UIFontDescriptorTraitsAttribute] = @{ UIFontSymbolicTrait: @(fontSymbolicTraits) };
    }
    else {
        NSMutableDictionary* newFontTraits = currentFontTraits.mutableCopy;
        newFontTraits[UIFontSymbolicTrait] = @(fontSymbolicTraits);
        _fontAttributes[UIFontDescriptorTraitsAttribute] = newFontTraits;
    }
#else
    NSDictionary<NSFontDescriptorTraitKey, id> * currentFontTraits = _fontAttributes[NSFontTraitsAttribute];
    if (currentFontTraits == nil) {
        _fontAttributes[NSFontTraitsAttribute] = @{ NSFontSymbolicTrait: @(fontSymbolicTraits) };
    }
    else {
        NSMutableDictionary* newFontTraits = currentFontTraits.mutableCopy;
        newFontTraits[NSFontSymbolicTrait] = @(fontSymbolicTraits);
        _fontAttributes[NSFontTraitsAttribute] = newFontTraits;
    }
#endif
}

@end

CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineSpacing = @"lineSpacing";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeParagraphSpacing = @"paragraphSpacing";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeAlignment = @"alignment";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeFirstLineHeadExtraIndent = @"firstLineHeadIndent";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeHeadExtraIndent = @"headIndent";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeTailExtraIndent = @"tailIndent";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineBreakMode = @"lineBreakMode";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeMinimumLineHeight = @"minimumLineHeight";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeMaximumLineHeight = @"maximumLineHeight";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineHeightMultiple = @"lineHeightMultiple";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeParagraphSpacingBefore = @"paragraphSpacingBefore";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeHyphenationFactor = @"hyphenationFactor";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemLabelIndent = @"listItemLabelIndent";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemBulletString = @"listItemBulletString";
CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemNumberFormat = @"listItemNumberFormat";
