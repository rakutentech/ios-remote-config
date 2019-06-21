Pod::Spec.new do |s|
  s.name         = "RRemoteConfig"
  s.version      = "0.0.1"
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Remote Config module."
  s.homepage     = "https://github.com/rakutentech/ios-remoteconfig"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/rakutentech/ios-remoteconfig.git", :tag => s.version.to_s }
  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.documentation_url = "https://github.com/rakutentech/ios-remoteconfig"
  s.pod_target_xcconfig = {
    'CLANG_ENABLE_MODULES'                                  => 'YES',
    'CLANG_MODULES_AUTOLINK'                                => 'YES',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'GCC_C_LANGUAGE_STANDARD'                               => 'gnu11',
    'OTHER_CFLAGS'                                          => "'-DRPT_SDK_VERSION=#{s.version.to_s}'"
  }
  s.user_target_xcconfig = {
    'CLANG_ENABLE_MODULES'                                  => 'YES',
    'CLANG_MODULES_AUTOLINK'                                => 'YES',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
  s.weak_frameworks = [
    'Foundation',
  ]
  s.source_files = "RRemoteConfig/**/*.{Swift,m}"
end
# vim:syntax=ruby:et:sts=2:sw=2:ts=2:ff=unix:
