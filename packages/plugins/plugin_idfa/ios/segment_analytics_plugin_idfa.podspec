#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plugin_idfa.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'segment_analytics_plugin_idfa'
  s.version          = '0.0.1'
  s.summary          = 'The hassle-free way to add Segment analytics to your Flutter app.'
  s.description      = <<-DESC
The hassle-free way to add Segment analytics to your Flutter app.
                       DESC
  s.homepage         = 'http://segment.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Segment' => 'support@segment.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
