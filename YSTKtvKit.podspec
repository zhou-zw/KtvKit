#
# Be sure to run `pod lib lint YSTKtvKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YSTKtvKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YSTKtvKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://221.131.123.204:8181/ios-mobile/modules/YSTKtvKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kuqiqi' => 'zhouzhenwei@ysten.com' }
  s.source           = { :git => 'http://221.131.123.204:8181/ios-mobile/modules/YSTKtvKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.xcconfig = {
    'ENABLE_BITCODE' => 'NO'
  }

  s.prefix_header_file = 'YSTKtvKit/Classes/Private/Common/YSTKtv.pch'

  non_arc_files = 'YSTKtvKit/Classes/Private/AudioUnit/*.m'
  s.exclude_files = non_arc_files
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  s.source_files = 'YSTKtvKit/Classes/**/*'

  s.public_header_files = 'YSTKtvKit/Classes/Public/*.h'
  
  s.resource_bundles = {
    'YSTKtvKit' => ['YSTKtvKit/Assets/*.{png,xib,mp4,mp3}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'

#s.dependency 'YSTPlayer'
# s.dependency 'YSTLanSDK'
  s.dependency 'MGJRouter'
end
