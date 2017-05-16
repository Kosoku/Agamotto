#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Agamotto'
  s.version          = '0.10.0'
  s.summary          = 'Agamotto is an iOS/macOS/tvOS/watchOS framework that provides block based extensions to KVO and NSNotificationCenter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Agamotto is an iOS/macOS/tvOS/watchOS framework that provides block based extensions to KVO and `NSNotificationCenter`. It supports removing the observations upon deallocation. It is based on a portion of the ReactiveCocoa Objective-C framework. It also provides a simplified version of RACCommand class, which can be assigned to various UI controls.
                       DESC

  s.homepage         = 'https://github.com/Kosoku/Agamotto'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'license.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/Agamotto.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  
  s.requires_arc = true

  s.source_files = 'Agamotto/**/*.{h,m}'
  s.exclude_files = 'Agamotto/Agamotto-Info.h'
  s.ios.exclude_files = 'Agamotto/macOS'
  s.osx.exclude_files = 'Agamotto/iOS'
  s.tvos.exclude_files = 'Agamotto/macOS'
  s.watchos.exclude_files = 'Agamotto/iOS', 'Agamotto/macOS'
  s.private_header_files = 'Agamotto/Private/*.h'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'Agamotto/*.{h,m}', 'Agamotto/Private/*.{h,m}'
    ss.exclude_files = 'Agamotto/Agamotto.h'
    
    ss.frameworks = 'Foundation'
    
    ss.dependency 'Stanley'
  end
  
  s.subspec 'UIKit' do |ss|
    ss.ios.deployment_target = '10.0'
    ss.tvos.deployment_target = '10.0'
    
    ss.source_files = 'Agamotto/iOS'
    
    ss.frameworks = 'Foundation', 'UIKit'
    
    ss.dependency 'Agamotto/Core'
  end
  
  s.subspec 'AppKit' do |ss|
    ss.osx.deployment_target = '10.12'
    
    ss.source_files = 'Agamotto/macOS'
    
    ss.frameworks = 'Foundation', 'AppKit'
    
    ss.dependency 'Agamotto/Core'
  end
end
