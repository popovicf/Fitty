# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Fitty' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Fitty

  target 'FittyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FittyUITests' do
    # Pods for testing
  end

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'FBSDKLoginKit'
pod 'SwiftyJSON'
pod 'IQKeyboardManager'
pod 'Firebase/Storage'
pod 'SDWebImage'
pod 'SDWebImageSwiftUI'
pod "LetterAvatarKit"
pod 'Firebase/Database'
pod 'NVActivityIndicatorView'
pod 'youtube-ios-player-helper'


end

post_install do |installer|
     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
            end
         end
     end
  end
