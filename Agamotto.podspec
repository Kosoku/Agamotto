#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Agamotto'
  s.version          = '0.5.0'
  s.summary          = 'Agamotto is an iOS/macOS/tvOS/watchOS framework that provides block based extensions to KVO.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Agamotto is an iOS/macOS/tvOS/watchOS framework that provides block based extensions to KVO. It supports removing the observations upon deallocation. It is based on a portion of the ReactiveCocoa Objective-C framework.
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
  s.osx.exclude_files = 'Agamotto/iOS'
  s.watchos.exclude_files = 'Agamotto/iOS'
  s.private_header_files = 'Agamotto/Private/*.h'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  s.frameworks = 'Foundation'
  
  s.dependency 'Stanley'
end
