$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'api/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api'
  s.version     = API::VERSION
  s.authors     = ['Sebastian Schkudlara']
  s.email       = ['sebastian.schkudlara@vizzuality.com']
  s.homepage    = 'http://www.vizzuality.com'
  s.summary     = 'API for UMDP Cabo Verde'
  s.description = ''
  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*', 'Rakefile']

  s.add_dependency 'responders', '~> 2.0'
  s.add_dependency 'active_model_serializers'
  s.add_dependency 'oj'
end
