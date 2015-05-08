# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/benchmarks/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-benchmarks'
  spec.version       = RSpec::Benchmarks::VERSION
  spec.authors       = ['Kantox LTD']
  spec.email         = ['aleksei.matiushkin@kantox.com']

  spec.summary       = 'Handy measures for rspec tests.'
  spec.description   = 'This gem provides different measures for rspec tests: amount of queries per example, execution time etc.'
  spec.homepage      = 'http://kantox.com'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'hashie', '~> 3.3'
  spec.add_dependency 'rspec-rails', '~> 2.14'
  spec.add_dependency 'rspec-expectations', '~> 2.14'

  spec.requirements << "gem 'kungfuig', git: 'git://github.com/am-kantox/kungfuig.git'"
end
