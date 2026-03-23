platform :ios, '13.0'

# Flag to switch between local and published SDKs
# Set to true to use local SDKs, false to use published versions from CocoaPods
USE_LOCAL_SDKS = false

target 'NimbblSampleApp' do
  use_frameworks!
  
  if USE_LOCAL_SDKS
    # Local SDKs for development
    pod 'nimbbl_mobile_kit_ios_core_api_sdk', :path => '../nimbbl_mobile_kit_ios_core_api_sdk'
    pod 'nimbbl_mobile_kit_ios_webview_sdk', :path => '../nimbbl_mobile_kit_ios_webview_sdk'
  else
    # Published SDKs from CocoaPods Trunk (only need WebView)
    pod 'nimbbl_mobile_kit_ios_webview_sdk', '2.0.17'
  end
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
