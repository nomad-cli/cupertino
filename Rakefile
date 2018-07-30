require 'bundler'
Bundler.setup

gemspec = eval(File.read('cupertino.gemspec'))

task build: "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ['cupertino.gemspec'] do
  system 'gem build cupertino.gemspec'
end
