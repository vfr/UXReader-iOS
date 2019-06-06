Pod::Spec.new do |s|
  s.name             = 'UXReader'
  s.version          = '0.1.1'
  s.platform         = :ios, '8.0'
  s.summary          = 'UXReader PDF Framework for iOS'
  s.homepage         = 'https://github.com/muyexi/UXReader-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'muyexi' => 'muyexi@gmail.com' }
  s.source           = { :git => 'https://github.com/muyexi/UXReader-iOS.git', :tag => s.version.to_s }
  s.vendored_frameworks = 'UXReader.framework'
  s.requires_arc = true
end
