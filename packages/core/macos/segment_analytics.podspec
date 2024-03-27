#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint segment_analytics.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'segment_analytics'
  s.version          = '0.0.1'
  s.summary          = 'Analytics Flutter MacOS plugin'
  s.description      = <<-DESC
Analytics Flutter MacOS plugin.
                       DESC
  s.homepage         = 'http://segment.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Christy Haragan' => 'charagan@twilio.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
