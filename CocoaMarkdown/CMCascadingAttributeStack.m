//
//  CMCascadingAttributeStack.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMCascadingAttributeStack.h"
#import "CMAttributeRun.h"
#import "CMPlatformDefines.h"
#import "CMStack.h"
#import "CMTextAttributes.h"

@interface CMFont (CMAdditions)
- (CMFont*) fontByAddingCMAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)addedFontAttributes;
@end

@interface NSParagraphStyle (CMAdditions)
+ (NSParagraphStyle*) paragraphStyleWithCMAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes;
- (NSParagraphStyle*) paragraphStyleByAddingCMAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes;
@end


@implementation CMCascadingAttributeStack {
    CMStack<CMAttributeRun*> *_stack;
    NSMutableArray<NSDictionary*> * _cascadedAttributes;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _stack = [[CMStack alloc] init];
        _cascadedAttributes = [NSMutableArray new];
    }
    return self;
}

- (void) pushAttributes:(CMStyleAttributes*)attributes
{
    [self push:CMDefaultAttributeRun(attributes)];
}

- (void) pushOrderedListAttributes:(CMStyleAttributes*)attributes withStartingNumber:(NSInteger)startingNumber
{
    [self push:CMOrderedListAttributeRun(attributes, startingNumber)];
}

- (CMStyleAttributes*) attributesWithDepth:(NSUInteger)depth
{
    return (depth < _stack.objects.count) ? _stack.objects[_stack.objects.count - 1 - depth].attributes : nil;
}

- (void)push:(CMAttributeRun *)run
{
    [_stack push:run];
}

- (void)pop
{
    [_stack pop];
    if (_cascadedAttributes.count > _stack.objects.count) {
        [_cascadedAttributes removeLastObject];
    }
}

- (CMAttributeRun *)peek
{
    return [_stack peek];
}

- (NSDictionary *)cascadedAttributes
{
    if (_cascadedAttributes.count < _stack.objects.count) {
        
        NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:_cascadedAttributes.lastObject ?: @{}];
        
        for (NSUInteger level = _cascadedAttributes.count; level < _stack.objects.count; level += 1) {

            CMStyleAttributes * currentStyleAttributes = _stack.objects[level].attributes;
            
            if (currentStyleAttributes != nil) {
                
                // Set explicit string attributes
                [combinedAttributes addEntriesFromDictionary:currentStyleAttributes.stringAttributes];
                
                // Set font attributes
                if (currentStyleAttributes.fontAttributes.count > 0) {
                    CMFont *baseFont = combinedAttributes[NSFontAttributeName];
                    CMFont *adjustedFont = nil;
                    if (baseFont != nil) {
                        adjustedFont = [baseFont fontByAddingCMAttributes:currentStyleAttributes.fontAttributes];
                    }
                    else {
                        CMFontDescriptor * adjustedFontDescriptor = [CMFontDescriptor fontDescriptorWithFontAttributes:currentStyleAttributes.fontAttributes];
                        if (adjustedFontDescriptor != nil) {
                            adjustedFont = [CMFont fontWithDescriptor:adjustedFontDescriptor size:adjustedFontDescriptor.pointSize];
                        }
                    }
                    if (adjustedFont != nil) {
                        combinedAttributes[NSFontAttributeName] = adjustedFont;
                    }
                }
                
                // Set paragraph style attributes
                if (currentStyleAttributes.paragraphStyleAttributes.count > 0) {
                    NSParagraphStyle* baseParagraphStyle = combinedAttributes[NSParagraphStyleAttributeName];
                    NSParagraphStyle* adjustedParagraphStyle = nil;
                    if (baseParagraphStyle != nil) {
                        adjustedParagraphStyle = [baseParagraphStyle paragraphStyleByAddingCMAttributes:currentStyleAttributes.paragraphStyleAttributes];
                    }
                    else {
                        adjustedParagraphStyle = [NSParagraphStyle paragraphStyleWithCMAttributes:currentStyleAttributes.paragraphStyleAttributes];
                    }
                    if (adjustedParagraphStyle != nil) {
                        combinedAttributes[NSParagraphStyleAttributeName] = adjustedParagraphStyle;
                    }
                }
            }
            
            [_cascadedAttributes addObject:combinedAttributes.copy];
        }
    }
    return _cascadedAttributes.lastObject;
}

@end


@implementation CMFont (CMAdditions)

#if TARGET_OS_IPHONE
#define CMFontNameAttribute UIFontDescriptorNameAttribute
#define CMFontFamilyAttribute UIFontDescriptorFamilyAttribute
#define CMFontTraitsAttribute UIFontDescriptorTraitsAttribute
#define CMFontDescriptorTraitKey UIFontDescriptorTraitKey
#define CMFontSymbolicTraitKey UIFontSymbolicTrait

#else
#define CMFontNameAttribute NSFontNameAttribute
#define CMFontFamilyAttribute NSFontFamilyAttribute
#define CMFontTraitsAttribute NSFontTraitsAttribute
#define CMFontDescriptorTraitKey NSFontDescriptorTraitKey
#define CMFontSymbolicTraitKey NSFontSymbolicTrait
#endif


- (CMFont*) fontByAddingCMAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)addedFontAttributes
{
    CMFont* matchingFont = nil;
    CMFontDescriptor* currentFontDescriptor = self.fontDescriptor;
    
#if TARGET_OS_IPHONE
    // Get the current font text style
    UIFontTextStyle currentFontTextStyle = [currentFontDescriptor objectForKey:UIFontDescriptorTextStyleAttribute] ?: UIFontTextStyleBody;
#endif
    
    if ([addedFontAttributes isKindOfClass:[NSDictionary class]] && (addedFontAttributes.count > 0)) {
        NSMutableDictionary<CMFontDescriptorAttributeName, id>* fontAttributes = [currentFontDescriptor.fontAttributes mutableCopy];
        
        if (((addedFontAttributes[CMFontTraitsAttribute] != nil) || (addedFontAttributes[CMFontFamilyAttribute] != nil)) 
            && (addedFontAttributes[CMFontNameAttribute] == nil)) {
            // Replace the font name in the font attributes by font-family
            fontAttributes[CMFontFamilyAttribute] = [currentFontDescriptor objectForKey:CMFontFamilyAttribute];
            [fontAttributes removeObjectForKey:CMFontNameAttribute];
        }
        
        if ((addedFontAttributes[CMFontFamilyAttribute] != nil) || (addedFontAttributes[CMFontNameAttribute] != nil)) {
            // A font is specified in the added attributes: Remove an eventual text-style font attribute as it could break the font change
#if TARGET_OS_IPHONE
            [fontAttributes removeObjectForKey:UIFontDescriptorTextStyleAttribute];
#else
            [fontAttributes removeObjectForKey:@"NSCTFontUIUsageAttribute"];
#endif
        }
        
        // Add the parameter attributes
        [fontAttributes addEntriesFromDictionary:addedFontAttributes];
        
        // If only font traits are added, try to preserve current font traits
        BOOL hasCombinedFontTraits = NO;
        NSDictionary<CMFontDescriptorTraitKey, id>* addedFontTraits = addedFontAttributes[CMFontTraitsAttribute];
        NSDictionary<CMFontDescriptorTraitKey, id>* currentFontTraits;
        if ((addedFontTraits != nil) && (addedFontAttributes.count == 1)) {
            currentFontTraits = [currentFontDescriptor objectForKey:CMFontTraitsAttribute];
            NSUInteger currentSymbolicTraits = [currentFontTraits[CMFontSymbolicTraitKey] unsignedIntValue];
            NSUInteger addedSymbolicTraits = [addedFontTraits[CMFontSymbolicTraitKey] unsignedIntValue];
            
            NSMutableDictionary<CMFontDescriptorTraitKey, id>* combinedFontTraits = [NSMutableDictionary new];
            [currentFontTraits enumerateKeysAndObjectsUsingBlock:^(CMFontDescriptorTraitKey traitKey, id traitValue, BOOL * _Nonnull stop) {
                if (![traitKey isEqualToString:CMFontSymbolicTraitKey] && ([traitValue doubleValue] != 0)) {
                    // Only keep traits with non-default value
                    combinedFontTraits[traitKey] = traitValue;
                }
            }];
            [combinedFontTraits addEntriesFromDictionary:addedFontAttributes[CMFontTraitsAttribute]];
            // Combine symbolic traits
            if ((currentSymbolicTraits != 0) && (addedSymbolicTraits != 0)) {
                combinedFontTraits[CMFontSymbolicTraitKey] = @(currentSymbolicTraits | addedSymbolicTraits);
            }
            fontAttributes[CMFontTraitsAttribute] = combinedFontTraits;
            hasCombinedFontTraits = YES;
        }
        
        // Get a font descriptor with the transformed font attributes
        CMFontDescriptor* matchingFontDescriptor = [CMFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
        
        if (hasCombinedFontTraits && (matchingFontDescriptor != nil)) {
            // Check if the font descriptor consistently creates a font with the expected font family
            NSString* expectedFontFamily = [matchingFontDescriptor objectForKey:CMFontFamilyAttribute];
            NSString* resultingFontFamily = [[CMFont fontWithDescriptor:matchingFontDescriptor size:0].fontDescriptor objectForKey:CMFontFamilyAttribute];
            if (! [resultingFontFamily isEqualToString:expectedFontFamily]) {
                // Retry without font traits attribute inheritance
                fontAttributes [CMFontTraitsAttribute] = addedFontTraits;
                matchingFontDescriptor = [CMFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
                
                // If added font traits break the expected font familly, ignore them
                resultingFontFamily = [[CMFont fontWithDescriptor:matchingFontDescriptor size:0].fontDescriptor objectForKey:CMFontFamilyAttribute];
                if (! [resultingFontFamily isEqualToString:expectedFontFamily]) {
                    // Restore current font traits
                    fontAttributes [CMFontTraitsAttribute] = currentFontTraits;
                    matchingFontDescriptor = [CMFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
                }
            }            
        }
        
        if (matchingFontDescriptor != nil) {
    
#if TARGET_OS_IPHONE
            if (@available(iOS 11.0, *)) {
                CGFloat currentStyleFontSize = [UIFont preferredFontForTextStyle:currentFontTextStyle].pointSize;
                CGFloat currentStyleBaseFontSize = [UIFont preferredFontForTextStyle:currentFontTextStyle 
                                                compatibleWithTraitCollection:[UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryMedium]].pointSize;
                UIFont* nonScalableFont = [UIFont fontWithDescriptor:matchingFontDescriptor 
                                                                size:matchingFontDescriptor.pointSize * currentStyleBaseFontSize / currentStyleFontSize];
                matchingFont = [[UIFontMetrics metricsForTextStyle:currentFontTextStyle] scaledFontForFont:nonScalableFont];
            }
            else {
                matchingFont = [UIFont fontWithDescriptor:matchingFontDescriptor size:matchingFontDescriptor.pointSize];
            }
#else   
            matchingFont = [CMFont fontWithDescriptor:matchingFontDescriptor size:matchingFontDescriptor.pointSize];
#endif

        }
    }

    return matchingFont;
}

@end


#pragma mark - NSParagraphStyle additions

@interface NSMutableParagraphStyle (CMAdditions)
- (void) applyParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes;
@end

@implementation NSParagraphStyle (CMAdditions)

+ (NSParagraphStyle*) paragraphStyleWithCMAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes
{
    NSMutableParagraphStyle* newParagraphStyle = nil;
    if ([paragraphStyleAttributes isKindOfClass:[NSDictionary class]] && (paragraphStyleAttributes.count > 0)) {
        newParagraphStyle = [NSMutableParagraphStyle new];
        [newParagraphStyle applyParagraphStyleAttributes:paragraphStyleAttributes];
    }
    return newParagraphStyle;
}

- (NSParagraphStyle*) paragraphStyleByAddingCMAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes
{
    NSMutableParagraphStyle* newParagraphStyle = nil;
    if ([paragraphStyleAttributes isKindOfClass:[NSDictionary class]] && (paragraphStyleAttributes.count > 0)) {
        newParagraphStyle = [self mutableCopy];
        [newParagraphStyle applyParagraphStyleAttributes:paragraphStyleAttributes];
    }
    return newParagraphStyle;
}

@end

@implementation NSMutableParagraphStyle (CMAdditions)

- (void) applyParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes
{
    static NSDictionary* applyAttributeBlocks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        applyAttributeBlocks = 
        @{ CMParagraphStyleAttributeLineSpacing: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.lineSpacing = [attribute doubleValue]; },
           CMParagraphStyleAttributeParagraphSpacing: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.paragraphSpacing = [attribute doubleValue]; },
           CMParagraphStyleAttributeAlignment: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.alignment = (NSTextAlignment)[attribute integerValue]; },
           CMParagraphStyleAttributeLineBreakMode: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.lineBreakMode = (NSLineBreakMode)[attribute integerValue]; },
           CMParagraphStyleAttributeMinimumLineHeight: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.minimumLineHeight = [attribute doubleValue]; },
           CMParagraphStyleAttributeMaximumLineHeight: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.maximumLineHeight = [attribute doubleValue]; },
           CMParagraphStyleAttributeLineHeightMultiple: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.lineHeightMultiple = [attribute doubleValue]; },
           CMParagraphStyleAttributeParagraphSpacingBefore: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.paragraphSpacingBefore = [attribute doubleValue]; },
           CMParagraphStyleAttributeHyphenationFactor: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.hyphenationFactor = [attribute floatValue]; },
           // Attributes with defining increment values
           CMParagraphStyleAttributeFirstLineHeadExtraIndent: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.firstLineHeadIndent += [attribute doubleValue]; },
           CMParagraphStyleAttributeHeadExtraIndent: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.headIndent += [attribute doubleValue]; },
           CMParagraphStyleAttributeTailExtraIndent: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){ paragraphStyle.tailIndent += [attribute doubleValue]; },
           
           // List-specific attributes (ignored)
           CMParagraphStyleAttributeListItemLabelIndent: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){},
           CMParagraphStyleAttributeListItemBulletString: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){},
           CMParagraphStyleAttributeListItemNumberFormat: ^(NSMutableParagraphStyle* paragraphStyle, id attribute){},
        };
    });
    
    [paragraphStyleAttributes enumerateKeysAndObjectsUsingBlock:^(CMParagraphStyleAttributeName attributeName, id attributeValue, BOOL * _Nonnull stop) {
        
        ((void(^)(NSMutableParagraphStyle* paragraphStyle, id attribute))applyAttributeBlocks[attributeName])(self, attributeValue);
    }];
}

@end
