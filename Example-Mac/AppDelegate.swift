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
    @IBOutlet weak var openPanelAUxiliaryView: NSView!
    @IBOutlet weak var linksBaseUrlTextField: NSTextField!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let testFileUrl = Bundle.main.url(forResource:"test", withExtension: "md") {
            renderMarkdownFile(atUrl: testFileUrl)
        }
    }
    
    @IBAction func selectMarkdownFile(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["md", "markdown"]
        panel.allowsMultipleSelection = false
        panel.prompt = "Render"
        panel.accessoryView = openPanelAUxiliaryView
        if #available(OSX 10.11, *) {
            panel.isAccessoryViewDisclosed = true
        }
        
        panel.beginSheetModal(for: window, completionHandler: { (response) in
            if response == .OK {
                if let selectedFileUrl = panel.url {
                    
                    var linksBaseUrl: URL? = nil
                    if self.linksBaseUrlTextField.stringValue.count > 0 {
                        linksBaseUrl = URL(string: self.linksBaseUrlTextField.stringValue)
                    }
                    
                    self.renderMarkdownFile(atUrl: selectedFileUrl, withLinksBaseUrl: linksBaseUrl)
                }
            }
        })
    }
    
    
    func renderMarkdownFile(atUrl url: URL, withLinksBaseUrl linksBaseUrl: URL? = nil) {
        let document = CMDocument(contentsOfFile: url.path, options: CMDocumentOptions(rawValue: 0))
        if linksBaseUrl != nil {
            document?.linksBaseURL = linksBaseUrl
        }
        
        let renderer = CMAttributedStringRenderer(document: document, attributes: CMTextAttributes())!
        renderer.register(CMHTMLStrikethroughTransformer())
        renderer.register(CMHTMLSuperscriptTransformer())
        renderer.register(CMHTMLUnderlineTransformer())
        
        if let renderedAttributedString = renderer.render(),
            let textStorage = textView.textStorage {
            textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length), with: renderedAttributedString)
        }
    }
}
