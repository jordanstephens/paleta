# -*- encoding: utf-8 -*-
require File.expand_path('../lib/paleta/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jordan Stephens']
  gem.email         = ['iam@jordanstephens.net']
  gem.description   = 'A gem for working with color palettes'
  gem.summary       = 'A little library for creating, manipulating and comparing colors and color palettes'
  gem.homepage      = 'http://rubygems.org/gems/paleta'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'paleta'
  gem.require_paths = ['lib']
  gem.version       = Paleta::VERSION

  gem.add_development_dependency "rspec", "~> 2.8"
  gem.add_development_dependency "guard-rspec", "~> 1.2"
  gem.add_development_dependency("pry-byebug", "~> 2.0") unless defined?(JRUBY_VERSION)
end
