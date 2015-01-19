//
//  CMParserDelegateFlags.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/19/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#ifndef CocoaMarkdown_CMParserDelegateFlags_h
#define CocoaMarkdown_CMParserDelegateFlags_h

typedef struct {
    unsigned int didStartDocument:1;
    unsigned int didEndDocument:1;
    unsigned int didAbort:1;
    unsigned int foundText:1;
    unsigned int foundHRule:1;
    unsigned int didStartHeader:1;
    unsigned int didEndHeader:1;
    unsigned int didStartParagraph:1;
    unsigned int didEndParagraph:1;
    unsigned int didStartEmphasis:1;
    unsigned int didEndEmphasis:1;
    unsigned int didStartStrong:1;
    unsigned int didEndStrong:1;
    unsigned int didStartLink:1;
    unsigned int didEndLink:1;
    unsigned int didStartImage:1;
    unsigned int didEndImage:1;
    unsigned int foundHTML:1;
    unsigned int foundInlineHTML:1;
    unsigned int foundCodeBlock:1;
    unsigned int foundInlineCode:1;
    unsigned int foundSoftBreak:1;
    unsigned int foundLineBreak:1;
    unsigned int didStartBlockQuote:1;
    unsigned int didEndBlockQuote:1;
    unsigned int didStartUnorderedList:1;
    unsigned int didEndUnorderedList:1;
    unsigned int didStartOrderedList:1;
    unsigned int didEndOrderedList:1;
    unsigned int didStartListItem:1;
    unsigned int didEndListItem:1;
} CMParserDelegateFlags;

NS_INLINE CMParserDelegateFlags CMParserDelegateFlagsForDelegate(id<CMParserDelegate> delegate) {
    return (CMParserDelegateFlags){
        .didStartDocument = [delegate respondsToSelector:@selector(parserDidStartDocument:)],
        .didEndDocument = [delegate respondsToSelector:@selector(parserDidEndDocument:)],
        .didAbort = [delegate respondsToSelector:@selector(parserDidAbort:)],
        .foundText = [delegate respondsToSelector:@selector(parser:foundText:)],
        .foundHRule = [delegate respondsToSelector:@selector(parserFoundHRule:)],
        .didStartHeader = [delegate respondsToSelector:@selector(parser:didStartHeaderWithLevel:)],
        .didEndHeader = [delegate respondsToSelector:@selector(parser:didEndHeaderWithLevel:)],
        .didStartParagraph = [delegate respondsToSelector:@selector(parserDidStartParagraph:)],
        .didEndParagraph = [delegate respondsToSelector:@selector(parserDidEndParagraph:)],
        .didStartEmphasis = [delegate respondsToSelector:@selector(parserDidStartEmphasis:)],
        .didEndEmphasis = [delegate respondsToSelector:@selector(parserDidEndEmphasis:)],
        .didStartStrong = [delegate respondsToSelector:@selector(parserDidStartStrong:)],
        .didEndStrong = [delegate respondsToSelector:@selector(parserDidEndStrong:)],
        .didStartLink = [delegate respondsToSelector:@selector(parser:didStartLinkWithURL:title:)],
        .didEndLink = [delegate respondsToSelector:@selector(parser:didEndLinkWithURL:title:)],
        .didStartImage = [delegate respondsToSelector:@selector(parser:didStartImageWithURL:title:)],
        .didEndImage = [delegate respondsToSelector:@selector(parser:didEndImageWithURL:title:)],
        .foundHTML = [delegate respondsToSelector:@selector(parser:foundHTML:)],
        .foundInlineHTML = [delegate respondsToSelector:@selector(parser:foundInlineHTML:)],
        .foundCodeBlock = [delegate respondsToSelector:@selector(parser:foundCodeBlock:info:)],
        .foundInlineCode = [delegate respondsToSelector:@selector(parser:foundInlineCode:)],
        .foundSoftBreak = [delegate respondsToSelector:@selector(parserFoundSoftBreak:)],
        .foundLineBreak = [delegate respondsToSelector:@selector(parserFoundLineBreak:)],
        .didStartBlockQuote = [delegate respondsToSelector:@selector(parserDidStartBlockQuote:)],
        .didEndBlockQuote = [delegate respondsToSelector:@selector(parserDidEndBlockQuote:)],
        .didStartUnorderedList = [delegate respondsToSelector:@selector(parser:didStartUnorderedListWithTightness:)],
        .didEndUnorderedList = [delegate respondsToSelector:@selector(parser:didEndUnorderedListWithTightness:)],
        .didStartOrderedList = [delegate respondsToSelector:@selector(parser:didStartOrderedListWithStartingNumber:tight:)],
        .didEndOrderedList = [delegate respondsToSelector:@selector(parser:didEndOrderedListWithStartingNumber:tight:)],
        .didStartListItem = [delegate respondsToSelector:@selector(parserDidStartListItem:)],
        .didEndListItem = [delegate respondsToSelector:@selector(parserDidEndListItem:)]
    };
}

#endif
