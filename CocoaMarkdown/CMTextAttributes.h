//
//  CMTextAttributes.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMPlatformDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, CMElementKind) {
    CMElementKindText = 1 << 0,
    
    CMElementKindHeader1 = 1 << 1,
    CMElementKindHeader2 = 1 << 2,
    CMElementKindHeader3 = 1 << 3,
    CMElementKindHeader4 = 1 << 4,
    CMElementKindHeader5 = 1 << 5,
    CMElementKindHeader6 = 1 << 6,
    CMElementKindAnyHeader = CMElementKindHeader1 | CMElementKindHeader2 | CMElementKindHeader3 | CMElementKindHeader4 | CMElementKindHeader5 | CMElementKindHeader6,
    
    CMElementKindParagraph = 1 << 7,
    CMElementKindLink = 1 << 8,
    CMElementKindImageParagraph = 1 << 9,
    CMElementKindCodeBlock = 1 << 10,
    CMElementKindInlineCode = 1 << 11,
    CMElementKindBlockQuote = 1 << 12,
    
    CMElementKindOrderedList = 1 << 13,
    CMElementKindOrderedSublist = 1 << 14,
    CMElementKindOrderedListItem = 1 << 15,
    CMElementKindUnorderedList = 1 << 16,
    CMElementKindUnorderedSublist = 1 << 17,
    CMElementKindUnorderedListItem = 1 << 18,
};

@class CMStyleAttributes;

typedef NSString * CMParagraphStyleAttributeName NS_EXTENSIBLE_STRING_ENUM;

/**
 *  Container for sets of text attributes used to style 
 *  attributed strings.
 */
@interface CMTextAttributes : NSObject

/**
 *  Initializes the receiver with the default attributes.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)init;

/// Set additional attributes for one or more element-kind
/// 
/// @param attributes A dictionary of string attributes that will be added to existing attributes for every specified element kind
/// @param elementKind The mask of target element kinds
///
- (void) addStringAttributes:(NSDictionary<NSAttributedStringKey, id>*)attributes forElementWithKinds:(CMElementKind)elementKinds;

/// Set additional font attributes for one or more element-kind
/// 
/// @param attributes A dictionary of font-descriptor attributes that will be added to existing attributes for every specified element kind
/// @param elementKind The mask of target element kinds
///
- (void) addFontAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)fontAttributes forElementWithKinds:(CMElementKind)elementKinds;

/// Set font traits for one or more element-kind
/// 
/// @param fontTraits A dictionary of font-trait attributes that will be set for every specified element kind
/// @param elementKind The mask of target element kinds
/// @description This is a specialized version of `addFontAttributes:forElementWithKinds:` dedicated to the font-trait attribute
///
- (void) setFontTraits:(NSDictionary<CMFontDescriptorTraitKey, id>*)fontTraits forElementWithKinds:(CMElementKind)elementKinds;

/// Set additional paragraph attributes for one or more element-kind
/// 
/// @param attributes A dictionary of string attributes that will be added to existing attributes for every specified element kind
/// @param elementKind The mask of target element kinds
///
- (void) addParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)attributes forElementWithKinds:(CMElementKind)elementKinds;

/**
 *  @param level The header level.
 *
 *  @return The attributes for the specified header level.
 */
- (CMStyleAttributes *)attributesForHeaderLevel:(NSInteger)level;

/**
 *  Attributes used to style text.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleBody`
 *  On OS X, defaults to using the user font with size 12pt.
 */
@property (nonatomic) CMStyleAttributes *baseTextAttributes;

/**
 *  Attributes used to style level 1 headers.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleHeadline`
 *  On OS X, defaults to using the user font with size 24pt.
 */
@property (nonatomic) CMStyleAttributes *h1Attributes;

/**
 *  Attributes used to style level 2 headers.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleHeadline`
 *  On OS X, defaults to using the user font with size 18pt.
 */
@property (nonatomic) CMStyleAttributes *h2Attributes;

/**
 *  Attributes used to style level 3 headers.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleHeadline`
 *  On OS X, defaults to using the user font with size 14pt.
 */
@property (nonatomic) CMStyleAttributes *h3Attributes;

/**
 *  Attributes used to style level 4 headers.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleSubheadline`
 *  On OS X, defaults to using the user font with size 12pt.
 */
@property (nonatomic) CMStyleAttributes *h4Attributes;

/**
 *  Attributes used to style level 5 headers.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleSubheadline`
 *  On OS X, defaults to using the user font with size 10pt.
 */
@property (nonatomic) CMStyleAttributes *h5Attributes;

/**
 *  Attributes used to style level 6 headers.
 *
 *  On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleSubheadline`
 *  On OS X, defaults to using the user font with size 8pt.
 */
@property (nonatomic) CMStyleAttributes *h6Attributes;

/**
 *  Attributes used to style paragraphs.
 *
 *  Defaults to using a 12pt paragraph spacing
 */
@property (nonatomic) CMStyleAttributes *paragraphAttributes;

/**
 *  Attributes used to style emphasized text.
 *
 *  If not set, the renderer will attempt to infer the emphasized font from the
 *  regular text font.
 */
@property (nonatomic) CMStyleAttributes *emphasisAttributes;

/**
 *  Attributes used to style strong text.
 *
 *  If not set, the renderer will attempt to infer the strong font from the
 *  regular text font.
 */
@property (nonatomic) CMStyleAttributes *strongAttributes;

/**
 *  Attributes used to style linked text.
 *
 *  Defaults to using a blue foreground color and a single line underline style.
 */
@property (nonatomic) CMStyleAttributes *linkAttributes;


/**
 *  Attributes used to style images paragraphs.
 *
 *  Defaults to centering the image.
 */
@property (nonatomic) CMStyleAttributes *imageParagraphAttributes;

/**
 *  Attributes used to style code blocks.
 *
 *  On iOS, defaults to the Menlo font when available, or Courier as a fallback.
 *  On OS X, defaults to the user monospaced font.
 */
@property (nonatomic) CMStyleAttributes *codeBlockAttributes;

/**
 *  Attributes used to style inline code.
 *
 *  On iOS, defaults to the Menlo font when available, or Courier as a fallback.
 *  On OS X, defaults to the user monospaced font.
 */
@property (nonatomic) CMStyleAttributes *inlineCodeAttributes;

/**
 *  Attributes used to style block quotes.
 *
 *  Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *blockQuoteAttributes;

/**
 *  Attributes used to style ordered lists.
 *
 *  These attributes will apply to the entire list (unless overriden by attributes
 *  for the list items), including the numbers.
 *
 *  Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *orderedListAttributes;

/**
 *  Attributes used to style unordered lists.
 *
 *  These attributes will apply to the entire list (unless overriden by attributes
 *  for the list items), including the bullets.
 *
 *  Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *unorderedListAttributes;

/**
 *  Attributes used to style ordered sublists.
 *
 *  These attributes will apply to the entire list (unless overriden by attributes
 *  for the list items), including the numbers.
 *
 *  Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *orderedSublistAttributes;

/**
 *  Attributes used to style unordered sublists.
 *
 *  These attributes will apply to the entire list (unless overriden by attributes
 *  for the list items), including the bullets.
 *
 *  Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *unorderedSublistAttributes;

/**
 *  Attributes used to style ordered list items.
 *
 *  These attribtues do _not_ apply to the numbers.
 */
@property (nonatomic) CMStyleAttributes *orderedListItemAttributes;

/**
 *  Attributes used to style unordered list items.
 *
 *  These attribtues do _not_ apply to the bullets.
 */
@property (nonatomic) CMStyleAttributes *unorderedListItemAttributes;

@end


@interface CMStyleAttributes: NSObject <NSCopying>

@property (readonly) NSMutableDictionary<NSAttributedStringKey, id> * stringAttributes;
@property (readonly) NSMutableDictionary<CMFontDescriptorAttributeName, id> * fontAttributes;
@property (readonly) NSMutableDictionary<CMParagraphStyleAttributeName, id> * paragraphStyleAttributes;

// Helper method for setting specific symbolic traits in fontAttributes
- (void) setFontSymbolicTraits:(CMFontSymbolicTraits)fontSymbolicTraits;

@end


extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineSpacing;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeParagraphSpacing;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeAlignment;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeFirstLineHeadExtraIndent;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeHeadExtraIndent;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeTailExtraIndent;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineBreakMode;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeMinimumLineHeight;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeMaximumLineHeight;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineHeightMultiple;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeParagraphSpacingBefore;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeHyphenationFactor;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemLabelIndent;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemBulletString;
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemNumberFormat;

NS_ASSUME_NONNULL_END
