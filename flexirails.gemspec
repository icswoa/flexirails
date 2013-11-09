# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flexirails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Raphael Randschau"]
  gem.email         = ["nicolai86@me.com"]
  gem.description   = %q{Dynamic tables in Ruby on Rails using simple ORM independent OO}
  gem.summary       = %q{Dynamic tables in Ruby on Rails}
  gem.homepage      = "http://blog.nicolai86.eu"
  gem.license       = 'MIT'
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = Dir["{app,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  gem.test_files    = Dir["test/**/*"]
  gem.name          = "flexirails"
  gem.require_paths = ["lib"]
  gem.version       = Flexirails::VERSION

  gem.add_dependency "url_plumber"
  gem.add_dependency "rails", "> 3.2.12", '< 5.0'
  gem.add_development_dependency 'sqlite3'
end

