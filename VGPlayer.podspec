#
# `pod lib lint VGPlayer.podspec' 
#  GitHub: https://github.com/VeinGuo/VGPlayer
#

Pod::Spec.new do |s|
  s.name         = "VGPlayer"
  s.version      = "0.2.0"
  s.summary      = "A simple iOS video player in Swift"
  s.description  = "A simple iOS video player in Swift by Vein."
  
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.homepage     = "https://github.com/VeinGuo/VGPlayer"
  s.author       = { "VeinGuo" => "https://github.com/VeinGuo" }

  s.ios.deployment_target = "8.0"
  s.platform     = :ios, "8.0"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }

  s.source       = { :git => "https://github.com/VeinGuo/VGPlayer.git", :tag => s.version }
  s.source_files = 'VGPlayer/Classes/*.*', 'VGPlayer/Classes/**/*.*'
  s.resources    = 'VGPlayer/*.xcassets'
  s.requires_arc = true
  s.dependency 'SnapKit', '~> 4.2.0'
  s.frameworks   = 'UIKit', 'AVFoundation', 'Foundation'

end

