#
# Be sure to run `pod lib lint DDPresenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DDPresenter'
  s.version          = '0.1.4'
  s.summary          = 'A short description of DDPresenter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/djs66256/DDPresenter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'daniel' => 'djs66256@163.com' }
  s.source           = { :git => 'https://github.com/djs66256/DDPresenter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

#   s.resource_bundles = {
#     'DDPresenter' => ['DDPresenter/Assets/*.png']
#   }

  s.swift_versions = '5.0'
  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'DDPresenter/Classes/Core/**/*'
    ss.frameworks = 'UIKit'
  end

  s.subspec 'NECollectionViewLayout' do |ss|
    ss.source_files = 'DDPresenter/Classes/NECollectionViewLayout/**/*'
    ss.dependency 'DDPresenter/Core'
    ss.dependency 'NECollectionViewLayout'
  end

  s.subspec 'CHTCollectionViewWaterfallLayout' do |ss|
    ss.source_files = 'DDPresenter/Classes/CHTCollectionViewWaterfallLayout/**/*'
    ss.dependency 'DDPresenter/Core'
    ss.dependency 'CHTCollectionViewWaterfallLayout'
  end
  
end
