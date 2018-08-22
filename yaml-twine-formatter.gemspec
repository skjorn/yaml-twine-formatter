Gem::Specification.new do |s|
  s.name        = 'yaml-twine-formatter'
  s.version     = '1.0.0'
  s.date        = '2018-08-22'
  s.summary     = 'A Twine formatter to YAML'
  s.description = 'A Twine formatter to YAML'
  s.authors     = ['Šimon Kručinin']
  s.email       = 'simon.krucinin@qest.cz'
  s.files       = ['lib/yaml-twine-formatter.rb']
  s.homepage    = 'http://rubygems.org/gems/yaml-twine-formatter'
  s.license     = 'MIT'
  s.metadata    = {
    'source_code_uri' => 'https://github.com/skjorn/yaml-twine-formatter'
  }
  
  s.add_runtime_dependency('twine', '~> 1')
  
end