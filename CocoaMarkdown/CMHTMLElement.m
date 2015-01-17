//
//  CMHTMLElement.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHTMLElement.h"
#import "CMHTMLElementTransformer.h"

@implementation CMHTMLElement {
    NSMutableAttributedString *_buffer;
}

- (instancetype)initWithTransformer:(id<CMHTMLElementTransformer>)transformer
{
    if ((self = [super init])) {
        _transformer = transformer;
        _buffer = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (NSString *)tagName;
{
    return [_transformer.class tagName];
}

- (void)appendString:(NSString *)string
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string];
    [self appendAttributedString:attrString];
}

- (void)appendAttributedString:(NSAttributedString *)attrString
{
    [_buffer appendAttributedString:attrString];
}

@end
