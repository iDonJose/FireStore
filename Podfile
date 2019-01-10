source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!



def pods
    # Firebase
    ## Issue with higher versions from 5.12, plus needs to be build with legacy system
    pod 'Firebase/Firestore', '~> 5.12.0'
	# Reactive
	pod 'ReactiveSwift', '~> 4.0'
	# Swift
	pod 'SwiftXtend', :path => '../../Frameworks/SwiftXtend'
	# Linting
	pod 'SwiftLint', '~> 0.28'
end

def test_pods

  pod 'Quick', '~> 1.3'
  pod 'Nimble', '~> 7.3'

end



target 'FireStore-iOS' do
  platform :ios, '8.0'

  pods

  target 'FireStore-Tests-iOS' do
    inherit! :search_paths
    
    test_pods

  end

end



post_install do |installer|
  installer.pods_project.targets.each do |target|

    target.new_shell_script_build_phase.shell_script = "mkdir -p $PODS_CONFIGURATION_BUILD_DIR/#{target.name}"

    target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
        config.build_settings['ENABLE_TESTABILITY'] = 'YES'
        config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end

  end
end
