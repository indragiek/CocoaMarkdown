//
//  AppDelegate.swift
//  Example-Mac
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

import Cocoa
import CocoaMarkdown

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let path = NSBundle.mainBundle().pathForResource("test", ofType: "md")!
//        let document = CMDocument(contentsOfFile: path, options: nil)
//        let text = ["## Hello","","```c","void main(){","}","```"].joinWithSeparator("\n")
//        let document = CMDocument(data: text.dataUsingEncoding(NSUTF8StringEncoding), options: CMDocumentOptions.Smart)
        let document = CMDocument(contentsOfFile: path, options: CMDocumentOptions.Smart)
        let renderer = CMAttributedStringRenderer(document: document, attributes: CMTextAttributes())
        renderer.registerHTMLElementTransformer(CMHTMLStrikethroughTransformer())
        renderer.registerHTMLElementTransformer(CMHTMLSuperscriptTransformer())
        renderer.registerHTMLElementTransformer(CMHTMLUnderlineTransformer())
        textView.textStorage?.appendAttributedString(renderer.render())
    }
}
