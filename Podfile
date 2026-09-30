platform :ios, '15.0'

# This Podfile integrates the NimbblSampleApp target.
#
# 2.1.0+ is not on the CocoaPods trunk (SPM-only there), so the SDK is consumed as
# a binary pod referenced directly from its public "pod" repo by git tag — this is
# trunk-independent and keeps working after the CocoaPods trunk read-only deadline.
#
# For local development against the pod repos, flip USE_LOCAL_POD_REPOS to true.
USE_LOCAL_POD_REPOS = false
VERSION = '2.1.0-alpha.1'
CORE_POD_GIT    = 'https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_core_api_pod.git'
WEBVIEW_POD_GIT = 'https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git'

target 'NimbblSampleApp' do
  use_frameworks!

  if USE_LOCAL_POD_REPOS
    # Local binary pod repos
    pod 'nimbbl_mobile_kit_ios_core_api_sdk', :path => '../../client-sdks/nimbbl_mobile_kit_ios_core_api_pod'
    pod 'nimbbl_mobile_kit_ios_webview_sdk',  :path => '../../client-sdks/nimbbl_mobile_kit_ios_webview_pod'
  else
    # Release: binary pods by git tag (Core must be given explicitly since the
    # WebView podspec depends on it and it is not on the trunk).
    pod 'nimbbl_mobile_kit_ios_core_api_sdk', :git => CORE_POD_GIT,    :tag => VERSION
    pod 'nimbbl_mobile_kit_ios_webview_sdk',  :git => WEBVIEW_POD_GIT, :tag => VERSION
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
