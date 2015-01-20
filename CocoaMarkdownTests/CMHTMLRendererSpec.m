#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <CocoaMarkdown/CocoaMarkdown.h>

QuickSpecBegin(CMHTMLRendererSpec)

it(@"should convert a document to HTML", ^{
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"test" ofType:@"md"];
    CMDocument *document = [[CMDocument alloc] initWithContentsOfFile:path];
    CMHTMLRenderer *renderer = [[CMHTMLRenderer alloc] initWithDocument:document options:0];
    expect([renderer render]).toNot(beNil());
});

QuickSpecEnd
