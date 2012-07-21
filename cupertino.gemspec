# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cupertino"

Gem::Specification.new do |s|
  s.name        = "cupertino"
  s.authors     = ["Mattt Thompson"]
  s.email       = "m@mattt.me"
  s.homepage    = "http://mattt.me"
  s.version     = Cupertino::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Cupertino"
  s.description = "A command-line interface for the iOS Provisioning Portal"

  s.add_development_dependency "rspec", "~> 0.6.1"
  s.add_development_dependency "rake",  "~> 0.9.2"

  s.add_dependency "commander", "~> 4.1.2"
  s.add_dependency "terminal-table", "~> 1.4.5"
  s.add_dependency "term-ansicolor", "~> 1.0.7"
  s.add_dependency "mechanize", "~> 2.5.1"
  s.add_dependency "security", "~> 0.1.2"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
