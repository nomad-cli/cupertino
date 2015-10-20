# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cupertino"
  s.version = "1.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mattt Thompson"]
  s.date = "2015-10-20"
  s.description = "A command-line interface for the iOS Provisioning Portal"
  s.email = "m@mattt.me"
  s.executables = ["ios"]
  s.files = ["./cupertino.gemspec", "./Gemfile", "./lib", "./lib/cupertino", "./lib/cupertino/provisioning_portal", "./lib/cupertino/provisioning_portal/agent.rb", "./lib/cupertino/provisioning_portal/commands", "./lib/cupertino/provisioning_portal/commands/app_ids.rb", "./lib/cupertino/provisioning_portal/commands/certificates.rb", "./lib/cupertino/provisioning_portal/commands/devices.rb", "./lib/cupertino/provisioning_portal/commands/login.rb", "./lib/cupertino/provisioning_portal/commands/logout.rb", "./lib/cupertino/provisioning_portal/commands/profiles.rb", "./lib/cupertino/provisioning_portal/commands.rb", "./lib/cupertino/provisioning_portal/helpers.rb", "./lib/cupertino/provisioning_portal.rb", "./lib/cupertino/version.rb", "./lib/cupertino.rb", "./LICENSE", "./Rakefile", "./README.md", "bin/ios"]
  s.homepage = "http://nomad-cli.com"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.14"
  s.summary = "Cupertino"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<commander>, ["~> 4.3"])
      s.add_runtime_dependency(%q<highline>, [">= 1.7.1"])
      s.add_runtime_dependency(%q<terminal-table>, ["~> 1.4.5"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.0.7"])
      s.add_runtime_dependency(%q<mechanize>, ["~> 2.5.1"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6.3"])
      s.add_runtime_dependency(%q<security>, ["~> 0.1.2"])
      s.add_runtime_dependency(%q<certified>, ["~> 1.0.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<commander>, ["~> 4.3"])
      s.add_dependency(%q<highline>, [">= 1.7.1"])
      s.add_dependency(%q<terminal-table>, ["~> 1.4.5"])
      s.add_dependency(%q<term-ansicolor>, ["~> 1.0.7"])
      s.add_dependency(%q<mechanize>, ["~> 2.5.1"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6.3"])
      s.add_dependency(%q<security>, ["~> 0.1.2"])
      s.add_dependency(%q<certified>, ["~> 1.0.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<commander>, ["~> 4.3"])
    s.add_dependency(%q<highline>, [">= 1.7.1"])
    s.add_dependency(%q<terminal-table>, ["~> 1.4.5"])
    s.add_dependency(%q<term-ansicolor>, ["~> 1.0.7"])
    s.add_dependency(%q<mechanize>, ["~> 2.5.1"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6.3"])
    s.add_dependency(%q<security>, ["~> 0.1.2"])
    s.add_dependency(%q<certified>, ["~> 1.0.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
