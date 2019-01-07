#  Validate Podspec by running 'pod spec lint <Framework>.podspec'
#  Podspec attributes : http://docs.cocoapods.org/specification.html
#  Podspecs examples : https://github.com/CocoaPods/Specs/

Pod::Spec.new do |s|

    s.name         = "FireStore"
    s.version      = "1.0.0"
    s.summary      = "Firebase Firestore and more"
    s.description  = <<-DESC
                        Extends Firebase Firestore with helpful methods.
                        DESC
    s.homepage     = "https://github.com/iDonJose/FireStore"
    s.source       = { :git => "https://github.com/iDonJose/FireStore.git", :tag => "#{s.version}" }

    s.license      = { :type => "Apache 2.0", :file => "LICENSE" }

    s.author       = { "iDonJose" => "donor.develop@gmail.com" }


    s.ios.deployment_target = "8.0"

    s.source_files = "Sources/**/*.h"
    s.source       = { :http => "https://github.com/iDonJose/FireStore/releases/download/1.0.0/FireStore.zip" }

    s.ios.vendored_frameworks = "FireStore.framework"

    #s.source_files  = "Sources/**/*.{h,swift}"

    #s.frameworks = "Foundation"
    #s.dependency "SwiftXtend", "~> 1.0"
	#s.dependency "ReactiveSwift", "~> 4.0"
    #s.dependency "Firebase/Firestore", "~> 5.12.0"

end
