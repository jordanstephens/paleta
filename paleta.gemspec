# -*- encoding: utf-8 -*-
require File.expand_path('../lib/paleta/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jordan Stephens']
  gem.email         = ['iam@jordanstephens.net']
  gem.description   = 'color palette gem'
  gem.summary       = 'color palette gem'
  gem.homepage      = 'http://jordanstephens.net'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'paleta'
  gem.require_paths = ['lib']
  gem.version       = Paleta::VERSION
end
