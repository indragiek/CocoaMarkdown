//
//  ViewController.swift
//  Example-iOS
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

import UIKit
import CocoaMarkdown

class ViewController: UIViewController {
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "test", ofType: "md")!
        let document = CMDocument(contentsOfFile: path, options: CMDocumentOptions(rawValue: 0))
        
        let renderer = CMAttributedStringRenderer(document: document, attributes: CMTextAttributes())!
        renderer.register(CMHTMLStrikethroughTransformer())
        renderer.register(CMHTMLSuperscriptTransformer())
        renderer.register(CMHTMLUnderlineTransformer())
        textView.attributedText = renderer.render()
    }
}

