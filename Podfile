
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'NimbblSampleApp' do
  # Use static linking to avoid embed phases
  use_frameworks! :linkage => :static

  # Pods for NimbblSampleApp
  # For development: Use local paths
  # For production: Use 'pod nimbbl_mobile_kit_ios_webview_sdk', '~> 1.0.0'
  pod 'nimbbl_mobile_kit_ios_webview_sdk', :path => '../nimbbl_mobile_kit_ios_webview_sdk'
  #pod 'nimbbl_mobile_kit_ios_webview_sdk', :git => 'https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git', :tag => '1.0.8'
  #pod 'nimbbl_mobile_kit_ios_core_api_sdk', '~> 1.0.3'
  
  # Override the core API SDK dependency to use local path for development
  pod 'nimbbl_mobile_kit_ios_core_api_sdk', :path => '../nimbbl_mobile_kit_ios_core_api_sdk'
end


