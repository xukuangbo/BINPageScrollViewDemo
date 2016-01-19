#
#  Be sure to run `pod spec lint BINPageScrollView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
Pod::Spec.new do |s| 
 
      s.name             = "BINPageScrollView"  
      s.version          = "1.0.0"  
      s.summary          = "A marquee view used on iOS."  
      s.description      = <<-DESC  
                           It is a marquee view used on iOS, which implement by Objective-C.  
                           DESC  
      s.homepage         = "https://github.com/BINDeveloper/BINPageScrollViewDemo"  
      # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"  
      s.license          = 'MIT'  
      s.author           = { "BinYu" => "bg1859710@gmail.com" }  
      s.source           = { :git => "https://github.com/BINDeveloper/BINPageScrollViewDemo.git", :tag => s.version.to_s }  
      # s.social_media_url = 'https://twitter.com/BinYu'  
      
      s.platform     = :ios, '7.0'  
      # s.ios.deployment_target = '6.0'  
      # s.osx.deployment_target = '10.7'  
      s.requires_arc = true  
      
      s.source_files = 'BINPageScrollViewDemo/*'  
      # s.resources = 'Assets'  
      
      # s.ios.exclude_files = 'Classes/osx'  
      # s.osx.exclude_files = 'Classes/ios'  
      # s.public_header_files = 'Classes/**/*.h'  
      s.frameworks = 'Foundation', 'UIKit'  
      
end