$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'cupertino/version'

Gem::Specification.new do |s|
  s.name        = 'cupertino'
  s.license     = 'MIT'
  s.authors     = ['Mattt Thompson']
  s.email       = 'm@mattt.me'
  s.homepage    = 'http://nomad-cli.com'
  s.version     = Cupertino::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Cupertino'
  s.description = 'A command-line interface for the iOS Provisioning Portal'

  s.add_dependency 'certified', '~> 1.0'
  s.add_dependency 'commander', '~> 4.4'
  s.add_dependency 'highline', '~> 1.7'
  s.add_dependency 'mechanize', '~> 2.7'
  s.add_dependency 'nokogiri', '~> 1.8'
  s.add_dependency 'security', '~> 0.1'
  s.add_dependency 'term-ansicolor', '~> 1.4'
  s.add_dependency 'terminal-table', '~> 1.8'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files         = Dir['./**/*'].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
