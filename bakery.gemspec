# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'bakery/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'bakery'
  s.version     = Bakery::Version.to_s
  s.authors     = ['Taylor Yelverton']
  s.email       = ['taylor@yelvert.io']
  s.homepage    = ''
  s.summary     = ''
  s.description = ''
  s.license     = 'MIT'

  s.files = Dir['{lib}/**/*']

  s.executables << 'bakery'

  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'down'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'pry-remote'

end
