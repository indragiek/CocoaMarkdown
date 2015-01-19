#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <CocoaMarkdown/CocoaMarkdown.h>

QuickSpecBegin(CMCommonMarkDocumentSpec)

describe(@"initialization", ^{
    
    __block NSString *path = nil;
    
    beforeSuite(^{
        path = [[NSBundle bundleForClass:self.class] pathForResource:@"test" ofType:@"md"];
    });
    
    it(@"should initialize from data", ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        CMCommonMarkDocument *document = [[CMCommonMarkDocument alloc] initWithData:data];
        expect(document.rootNode).toNot(beNil());
    });
    
    it(@"should initialize from a file", ^{
        CMCommonMarkDocument *document = [[CMCommonMarkDocument alloc] initWithContentsOfFile:path];
        expect(document.rootNode).toNot(beNil());
    });
    
    it(@"should not initialize for an invalid file path", ^{
        CMCommonMarkDocument *document = [[CMCommonMarkDocument alloc] initWithContentsOfFile:@"/nonexistent/path"];
        expect(document).to(beNil());
    });
});

QuickSpecEnd
