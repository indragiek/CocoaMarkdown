#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <CocoaMarkdown/CocoaMarkdown.h>

QuickSpecBegin(CMDocumentSpec)

describe(@"initialization", ^{
    
    __block NSString *path = nil;
    
    beforeSuite(^{
        path = [[NSBundle bundleForClass:self.class] pathForResource:@"test" ofType:@"md"];
    });
    
    it(@"should initialize from data", ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        CMDocument *document = [[CMDocument alloc] initWithData:data];
        expect(document.rootNode).toNot(beNil());
    });
    
    it(@"should initialize from a file", ^{
        CMDocument *document = [[CMDocument alloc] initWithContentsOfFile:path];
        expect(document.rootNode).toNot(beNil());
    });
    
    it(@"should not initialize for an invalid file path", ^{
        CMDocument *document = [[CMDocument alloc] initWithContentsOfFile:@"/nonexistent/path"];
        expect(document).to(beNil());
    });
});

QuickSpecEnd
