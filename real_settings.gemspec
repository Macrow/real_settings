# -*- encoding: utf-8 -*-
require File.expand_path('../lib/real_settings/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Macrow"]
  gem.email         = ["Macrow_wh@163.com"]
  gem.description   = %q{A real settings tool for Rails3}
  gem.summary       = %q{A real settings tool for Rails3}
  gem.homepage      = "https://github.com/Macrow/real_settings"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "real_settings"
  gem.require_paths = ["lib"]
  gem.version       = RealSettings::VERSION
  
  gem.add_dependency 'rails'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sqlite3'
end
