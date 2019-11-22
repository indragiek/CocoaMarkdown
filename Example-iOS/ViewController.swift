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
        
        let textAttributes = CMTextAttributes()
        
        // Customize the color and font of header elements
        textAttributes.addStringAttributes([ .foregroundColor: UIColor(red: 0.0, green: 0.446, blue: 0.657, alpha: 1.0)], forElementWithKinds: .anyHeader)
        let boldItalicTrait: UIFontDescriptor.SymbolicTraits = [.traitBold, .traitItalic]
        textAttributes.addFontAttributes([ .family: "Avenir Next" ,
                                           .traits: [ UIFontDescriptor.TraitKey.symbolic: boldItalicTrait.rawValue]], 
                                         forElementWithKinds: .anyHeader)
        textAttributes.setFontTraits([.weight: UIFont.Weight.heavy], forElementWithKinds: [.header1, .header2])
        textAttributes.addFontAttributes([ .size: 40 ], forElementWithKinds: .header1)
        
        // Customize the font and paragraph alignment of block-quotes
        textAttributes.addFontAttributes([.family: "Noteworthy", .size: 18], forElementWithKinds: .blockQuote)
        textAttributes.addParagraphStyleAttributes([ .alignment: NSTextAlignment.center.rawValue], forElementWithKinds: .blockQuote)
        
        // Customize the background color of code elements
        textAttributes.addStringAttributes([ .backgroundColor: UIColor(white: 0.9, alpha: 0.5)], forElementWithKinds: [.inlineCode, .codeBlock])
        
        let renderer = CMAttributedStringRenderer(document: document, attributes: textAttributes)!
        renderer.register(CMHTMLStrikethroughTransformer())
        renderer.register(CMHTMLSuperscriptTransformer())
        renderer.register(CMHTMLUnderlineTransformer())
        textView.attributedText = renderer.render()
    }
}

