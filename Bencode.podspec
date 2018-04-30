Pod::Spec.new do |s|
  s.name             = 'Bencode'
  s.version          = '1.5.0'
  s.summary          = 'Pure swift Bencode decoder & encoder'

  s.description      = <<-DESC
This pod is a general purpose Bencode encoder & decoder.
Can be used for e.g.: decoding .torrent files.
                       DESC

  s.homepage         = 'https://github.com/danieltmbr/Bencode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danieltmbr' => 'daniel@tmbr.me' }
  s.source           = { :git => 'https://github.com/danieltmbr/Bencode.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/danieltmbr'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Source/*.swift'

end
