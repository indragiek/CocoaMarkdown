//
//  CMHTMLStrikethroughTransformer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHTMLStrikethroughTransformer.h"
#import "Ono.h"

@implementation CMHTMLStrikethroughTransformer {
    NSUnderlineStyle _style;
    CMColor *_color;
}

- (instancetype)init
{
    return [self initWithStrikethroughStyle:NSUnderlineStyleSingle color:CMColor.blackColor];
}

- (instancetype)initWithStrikethroughStyle:(NSUnderlineStyle)style color:(CMColor *)color
{
    if ((self = [super init])) {
        _style = style;
        _color = color;
    }
    return self;
}

+ (NSString *)tagName { return @"s"; };

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    NSAssert([element.tag isEqualToString:self.class.tagName], @"Root element must be a strikethrough element");
    
    NSMutableDictionary *baseAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(NSUnderlineStyleSingle), NSStrikethroughStyleAttributeName, nil];
    [baseAttributes addEntriesFromDictionary:attributes];
    
    return [[NSAttributedString alloc] initWithString:element.stringValue attributes:baseAttributes];
}

@end
