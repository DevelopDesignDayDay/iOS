# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DDD' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # ignore all warnings from all pods
  inhibit_all_warnings!

  # Network
  pod 'Himotoki'
  pod 'Alamofire'
  pod 'SwiftyJSON', '~> 4.0'

  # Rx
  pod 'RxSwift',    '~> 4.0'
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'RxSwift'
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.0'
                  config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
                  if config.name == 'Debug'
                      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                  end
              end
          end
      end
  end
  
  pod 'RxCocoa',    '~> 4.0'
  pod 'RxOptional'
  pod 'RxSwiftExt'
  pod 'RxDataSources'

  # UI
  pod 'SDWebImage', '~> 4.0'
  pod 'IQKeyboardManagerSwift'
  pod 'TPKeyboardAvoiding', :git => 'https://github.com/michaeltyson/TPKeyboardAvoiding.git'
  pod 'SVProgressHUD'
  pod 'MaterialTextField'
  pod 'lottie-ios'
  
  target 'DDDTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DDDUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
