Pod::Spec.new do |s|
  s.name             = 'QnABotMaker'
  s.version          = '1.0.3'
  s.summary          = 'Simplifies working with Microsoft QnA Maker on iOS.'

  s.description   = <<-DESC
      Convenience library for working with Microsoft QnA Maker Service
  DESC

  s.homepage         = 'https://github.com/benbahrenburg/QnABotMaker'
  s.license          = 'MIT'
  s.authors          = { 'Ben Bahrenburg' => 'hello@bencoding.com' }
  s.source           = { :git => 'https://github.com/benbahrenburg/QnABotMaker.git', :tag => s.version }
  s.social_media_url = 'https://twitter.com/bencoding'
  s.ios.deployment_target = '10.0'
  s.source_files = 'QnABotMaker/Classes/**/*'
end
