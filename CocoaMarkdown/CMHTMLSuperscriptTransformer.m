//
//  CMHTMLSuperscriptTransformer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHTMLSuperscriptTransformer.h"
#import "CMHTMLScriptTransformer_Private.h"

@implementation CMHTMLSuperscriptTransformer

- (instancetype)init
{
    return [self initWithFontSizeRatio:0.7];
}

- (instancetype)initWithFontSizeRatio:(CGFloat)ratio
{
    return [super initWithStyle:CMHTMLScriptStyleSuperscript fontSizeRatio:ratio];
}

#pragma mark - CMHTMLElementTransformer

+ (NSString *)tagName { return @"sup"; };

@end
