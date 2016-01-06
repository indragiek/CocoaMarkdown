Pod::Spec.new do |s|

  s.name         = "CocoaMarkdown"
  s.version      = "0.1.0"
  s.summary      = "Markdown parsing and rendering for iOS and OS X"

  s.description  = "CocoaMarkdown aims to solve two primary problems better than existing libraries:
More flexibility. CocoaMarkdown allows you to define custom parsing hooks or even traverse the Markdown AST using the low-level API.
Efficient NSAttributedString creation for easy rendering on iOS and OS X. Most existing libraries just generate HTML from the Markdown, which is not a convenient representation to work with in native apps."

  s.homepage     = "https://github.com/indragiek/CocoaMarkdown"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = "Indragie Karunaratne"
  s.platform     = :ios

  s.source       = { :git => "https://github.com/X8/CocoaMarkdown.git", :tag => "0.1.0" }
  s.source_files  = "CocoaMarkdown"

  s.framework  = "UIKit"
  
  s.dependency 'cmark'
  s.dependency 'Ono'
    


end