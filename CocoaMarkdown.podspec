Pod::Spec.new do |s|
  
  s.name          = 'CocoaMarkdown'
  s.version       = '1.0'
  s.summary       = 'Markdown parsing and rendering for iOS and OS X'
  s.description   = "CocoaMarkdown aims to solve two primary problems better than existing libraries:
More flexibility. CocoaMarkdown allows you to define custom parsing hooks or even traverse the Markdown AST using the low-level API.
Efficient NSAttributedString creation for easy rendering on iOS and OS X. Most existing libraries just generate HTML from the Markdown, which is not a convenient representation to work with in native apps."

  s.homepage      = 'https://github.com/indragiek/CocoaMarkdown'
  s.license       = 'MIT'

  s.author        = "Indragie Karunaratne"
  s.platform      = :ios, '8.0'

  s.source        = { :git => 'https://github.com/indragiek/CocoaMarkdown.git' }
  s.source_files  = 'CocoaMarkdown'
  s.framework     = 'UIKit'
  s.requires_arc  = true

  s.dependency 'cmark', '~> 0.21.0'
  s.dependency 'Ono', '~> 1.1.3'

end
