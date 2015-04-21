# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fling/version'

Gem::Specification.new do |spec|
  spec.name          = "fling"
  spec.version       = Fling::VERSION
  spec.authors       = ["Tony Arcieri"]
  spec.email         = ["bascule@gmail.com"]

  spec.summary       = "Simple secret sharing over Tahoe-LAFS"
  spec.description   = "Fling is a system for automating the exchange of files and directories over Tahoe-LAFS, a distributed encrypted filesystem."
  spec.homepage      = "https://github.com/tarcieri/fling"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
