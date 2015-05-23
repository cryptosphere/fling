# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fling/version"

Gem::Specification.new do |spec|
  spec.name          = "fling"
  spec.version       = Fling::VERSION
  spec.authors       = ["Tony Arcieri"]
  spec.email         = ["bascule@gmail.com"]

  spec.summary       = "Simple secret sharing over Tahoe-LAFS"
  spec.description   = "Fling is a system for automating the exchange of files and directories" \
                       "over Tahoe-LAFS, a distributed encrypted filesystem."
  spec.homepage      = "https://github.com/tarcieri/fling"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "base32"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
end
