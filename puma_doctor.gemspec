# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puma_doctor/version'

Gem::Specification.new do |spec|
  spec.name          = "puma_doctor"
  spec.version       = PumaDoctor::VERSION
  spec.authors       = ["Alex Krasynskyi"]
  spec.email         = ["lyoshakr@gmail.com"]
  spec.summary       = %q{Process to keep your puma workers healthy}
  spec.description   = %q{Kills largest workers.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['puma_doctor']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "daemons"
  spec.add_dependency "get_process_mem"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
