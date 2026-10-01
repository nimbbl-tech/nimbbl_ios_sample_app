platform :ios, '15.0'

# This Podfile integrates the NimbblSampleApp target.
#
# The SDK is published on the CocoaPods trunk, so it's consumed the standard way:
# add only the WebView pod and the Core API SDK resolves transitively. For local
# development against the pod repos, flip USE_LOCAL_POD_REPOS to true.
USE_LOCAL_POD_REPOS = false
NIMBBL_SDK_VERSION  = '2.1.0-alpha.4'

target 'NimbblSampleApp' do
  use_frameworks!

  if USE_LOCAL_POD_REPOS
    # Local binary pod repos (Core must be given explicitly for the local path).
    pod 'nimbbl_mobile_kit_ios_core_api_sdk', :path => '../../client-sdks/nimbbl_mobile_kit_ios_core_api_pod'
    pod 'nimbbl_mobile_kit_ios_webview_sdk',  :path => '../../client-sdks/nimbbl_mobile_kit_ios_webview_pod'
  else
    # Published on the CocoaPods trunk — add only WebView; Core resolves
    # transitively from its podspec dependency.
    pod 'nimbbl_mobile_kit_ios_webview_sdk', NIMBBL_SDK_VERSION
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
