#
# Be sure to run `pod lib lint ludio.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ludio'
  s.version          = '0.1.0'
  s.summary          = 'Video Player library used for capturing and playback back video'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Ludio is library used to capture and playback video.
                       DESC

  s.homepage         = 'https://github.com/zachmanc/ludio-ios.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cory Zachman' => 'zachmanc@gmail.com' }
  s.source           = { :git => 'https://github.com/zachmanc/ludio-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'ludio/Classes/**/*'
end
