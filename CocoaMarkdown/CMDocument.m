//
//  CMDocument.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMDocument_Private.h"
#import "CMNode_Private.h"

@interface CMDocument ()
@property (nonatomic, readonly) NSArray *lines;
@end

@implementation CMDocument
@synthesize lines = _lines;

- (instancetype)initWithData:(NSData *)data options:(CMDocumentOptions)options
{
    NSParameterAssert(data);
    
    if ((self = [super init])) {
        cmark_node *node = cmark_parse_document((const char *)data.bytes, data.length, options);
        if (node == NULL) return nil;
        
        _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
        _text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        _options = options;
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)path options:(CMDocumentOptions)options error:(NSError *__autoreleasing *)errorPtr
{
    if ((self = [super init])) {
        FILE *fp = fopen(path.UTF8String, "r");
        if (fp == NULL) return nil;
        
        cmark_node *node = cmark_parse_file(fp, options);
        fclose(fp);
        if (node == NULL) return nil;
        
        _rootNode = [[CMNode alloc] initWithNode:node freeWhenDone:YES];
        
        NSError *error = nil;
        _text = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (_text == nil) {
            if (errorPtr != NULL) {
                *errorPtr = error;
            }
            return nil;
        }
        _options = options;
    }
    return self;
}

- (NSArray *)lines
{
    if (_lines == nil) {
        _lines = [_text componentsSeparatedByString:@"\n"];
    }
    return _lines;
}

- (NSUInteger)indexForLine:(NSUInteger)line column:(NSUInteger)column
{
    NSUInteger index = 0;
    for (NSInteger i = 1; i < line; i++) {
        index += [(NSString *)self.lines[i - 1] length] + 1; // Add 1 for newline
    }
    index += column - 1;
    return index;
}

- (NSString *)substringForNode:(CMNode *)node
{
    if (node.startLine == 0 || node.startColumn == 0 || node.endLine == 0 || node.endColumn == 0) {
        return nil;
    }
    
    const NSUInteger startIndex = [self indexForLine:node.startLine column:node.startColumn];
    const NSUInteger endIndex = [self indexForLine:node.endLine column:node.endColumn];
    NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
    range = [_text rangeOfComposedCharacterSequencesForRange:range];
    return [_text substringWithRange:range];
}

@end
