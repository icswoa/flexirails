# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flexirails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Raphael Randschau"]
  gem.email         = ["nicolai86@me.com"]
  gem.description   = %q{Flexirails}
  gem.summary       = %q{Flexirails}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "flexirails"
  gem.require_paths = ["lib"]
  gem.version       = Flexirails::VERSION

  gem.add_dependency "jquery-rails"
end

