//
//  CMImageTextAttachment.h
//  CocoaMarkdown
//
//  Created by Jean-Luc on 10/05/2019.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//
@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import Cocoa;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CMImageTextAttachment : NSTextAttachment

- (instancetype) initWithImageURL:(NSURL*)imageURL;

@property (nonatomic, readonly) NSURL* imageURL;

@end

NS_ASSUME_NONNULL_END
