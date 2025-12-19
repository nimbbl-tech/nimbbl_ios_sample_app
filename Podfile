platform :ios, '13.0'
target 'NimbblSampleApp' do
  use_frameworks!
  
  # Default: Use published SDKs
  # To use local SDKs, create a file named '.use_local_sdks' in this directory
  # Run: touch .use_local_sdks (to enable) or rm .use_local_sdks (to disable)
  use_local_sdks = File.exist?('.use_local_sdks')
  
  if use_local_sdks
    # Local SDKs for development
    core_api_local_path = '../nimbbl_mobile_kit_ios_core_api_sdk'
    webview_local_path = '../nimbbl_mobile_kit_ios_webview_sdk'
    pod 'nimbbl_mobile_kit_ios_core_api_sdk', :path => core_api_local_path
    pod 'nimbbl_mobile_kit_ios_webview_sdk', :path => webview_local_path
  else
    # Published SDKs - only need to declare webview SDK, Core API SDK is transitive dependency
    # Using patch version 2.0.16 with nested framework fix
    pod 'nimbbl_mobile_kit_ios_webview_sdk', '2.0.16'
  end
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      # Ensure code signing is disabled for local development pods
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
