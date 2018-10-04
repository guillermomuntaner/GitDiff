Pod::Spec.new do |s|
  s.name             = 'GitDiff'
  s.version          = '0.1.0'
  s.summary          = 'Parse git unified diffs with Swift.'
  s.homepage         = 'https://github.com/guillermomuntaner/GitDiff'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillermo Muntaner' => 'guillermomp87@gmail.com' }
  s.source           = { :git => 'https://github.com/guillermomuntaner/GitDiff.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/guillermomp87'

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.source_files = 'GitDiff/Classes/**/*'
  
  s.frameworks = 'Foundation'
end
