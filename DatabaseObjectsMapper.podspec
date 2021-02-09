#
# Be sure to run `pod lib lint DatabaseObjectsMapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DatabaseObjectsMapper'
  s.version          = '0.4'
  s.summary          = 'DatabaseObjectsMapper implementation.'

  s.description      = <<-DESC
DatabaseObjectsMapper implementation.
                       DESC

  s.homepage         = 'https://bitbucket.org/MikhailMulyar/databaseobjectmapper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mikhailmulyar' => 'mulyarm@gmail.com' }
  s.source           = { :git => 'https://bitbucket.org/MikhailMulyar/databaseobjectmapper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'DatabaseObjectsMapper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DatabaseObjectsMapper' => ['DatabaseObjectsMapper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreData'
  s.dependency 'RealmSwift', '~> 10.5'
  s.dependency 'DictionaryCoding', '~> 1.0'
end
