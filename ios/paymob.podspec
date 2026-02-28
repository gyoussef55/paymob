#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint paymob.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'paymob'
  s.version          = '1.1.2'
  s.summary          = 'A Flutter plugin for integrating Paymob payment SDK.'
  s.description      = <<-DESC
A Flutter plugin for integrating Paymob payment SDK. Provides easy integration with Paymob's native SDKs for iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/gyoussef55/paymob'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'gyoussef55' => 'https://github.com/gyoussef55' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_CONFIGURATION_BUILD_DIR}" "${PODS_ROOT}/../Frameworks" "${PODS_ROOT}/../../Frameworks" "${SRCROOT}/Frameworks" "${SRCROOT}/../Frameworks" "${SRCROOT}/../../Frameworks" "${BUILT_PRODUCTS_DIR}" "${PODS_TARGET_SRCROOT}/../Frameworks"',
    'OTHER_LDFLAGS' => '$(inherited) -framework PaymobSDK',
    'SWIFT_INCLUDE_PATHS' => '$(inherited) "${PODS_ROOT}/../Frameworks" "${SRCROOT}/Frameworks"'
  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'paymob_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
