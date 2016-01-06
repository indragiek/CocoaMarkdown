#import <Quick/Quick.h>
#import <CocoaMarkdown/CocoaMarkdown.h>
@import Nimble;

QuickSpecBegin(CMHTMLRendererSpec)

it(@"should convert a document to HTML", ^{
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"test" ofType:@"md"];
    CMDocument *document = [[CMDocument alloc] initWithContentsOfFile:path options:0];
    CMHTMLRenderer *renderer = [[CMHTMLRenderer alloc] initWithDocument:document];
    expect([renderer render]).toNot(beNil());
});

QuickSpecEnd
