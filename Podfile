platform :ios, '13.0'
target 'NimbblSampleApp' do
  use_frameworks!
  
  # Published SDKs - only need to declare webview SDK, Core API SDK is transitive dependency
  # Using patch version 2.0.16 with nested framework fix
  pod 'nimbbl_mobile_kit_ios_webview_sdk', '2.0.16'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
