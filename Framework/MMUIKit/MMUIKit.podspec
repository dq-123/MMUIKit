

Pod::Spec.new do |s|

  s.name         = "MMUIKit"
  s.version      = "1.0.1"
  s.summary      = "MMKit纯UIWebView版本"

  s.license      = { :type => "MIT License", :file => "LICENSE" }
  s.homepage     = "https://google.com"
  s.author       = { "CoderDwang" => "Customer Service System" }

  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.frameworks = "CoreLocation", "MobileCoreServices", "Security", "CoreGraphics", "SystemConfiguration", "CoreTelephony", "CoreFoundation", "CFNetwork", "JavaScriptCore", "UIKit", "Foundation"
  s.weak_frameworks = "UserNotifications"
  s.libraries = "sqlite3", "icucore", "c++", "resolv", "z"
  s.resources     = "MMKitResouce.bundle"
  s.xcconfig = {'OTHER_LDFLAGS' => '-ObjC'}
  s.xcconfig = {'OTHER_LDFLAGS' => '-force_load $(PROJECT_DIR)/MMUIKit/MMUIKit.framework/MMUIKit'}
  s.xcconfig = {'ENABLE_BITCODE' => 'NO'}
  s.source       = { :git => ""}
  s.vendored_frameworks = 'MMUIKit.framework'

end


