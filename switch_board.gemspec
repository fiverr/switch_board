# -*- encoding: utf-8 -*-

require File.expand_path('../lib/switch_board/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "switch_board"
  gem.version       = SwitchBoard::VERSION
  gem.summary       = %q{Coordinate a set of persisted data and distribute to an active set of registerd clients}
  gem.description   = %q{Coordinate a set of persisted data models and distribute to an active set of registerd clients.  Allows locking and automatic expiration for locking on portions of the data}
  gem.license       = "MIT"
  gem.authors       = ["Avner Cohen"]
  gem.email         = "israbirding@gmail.com"
  gem.homepage      = "https://rubygems.org/gems/switch_board"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rdoc', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
