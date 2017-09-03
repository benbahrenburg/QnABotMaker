Pod::Spec.new do |s|
  s.name             = 'QnABotMaker'
  s.version          = '0.1.0'
  s.summary          = 'Convenience library for working with Microsoft QnA Maker Service'

  s.description   = <<-DESC
      Simplifies working with Microsoft QnA Maker on iOS.
  DESC

  s.homepage         = 'https://github.com/benbahrenburg/QnABotMaker'
  s.license          = 'MIT'
  s.authors          = { 'Ben Bahrenburg' => 'hello@bencoding.com' }
  s.source           = { :git => 'https://github.com/benbahrenburg/QnABotMaker.git', :tag => s.version }
  s.social_media_url = 'https://twitter.com/bencoding'
  s.ios.deployment_target = '10.0'
  s.source_files = 'QnABotMaker/Classes/**/*'
end
