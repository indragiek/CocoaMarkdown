
platform :ios, '8.0'
use_frameworks!

target 'CocoaMarkdown-iOS' do
  pod 'Ono'
  pod 'cmark'
end

target 'CocoaMarkdown-Mac' do
  pod 'Ono'
  pod 'cmark'
end

abstract_target "Tests" do
  pod 'Ono'
  pod 'cmark'
  pod 'Nimble'
  pod 'Quick'
  target "CocoaMarkdownTests-iOS"
  target 'CocoaMarkdownTests-Mac'
end
