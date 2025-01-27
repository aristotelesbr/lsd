# frozen_string_literal: true

require_relative "lib/lsd/version"

Gem::Specification.new do |spec|
  spec.name = "lsd-rb"
  spec.version = Lsd::VERSION
  spec.authors = ["Aristóteles Coutinho"]
  spec.email = ["contato@aristoteles.dev"]

  spec.summary = "A modern replacement for ls command"
  spec.description = "List directory contents with a modern, colorful interface"
  spec.homepage = "https://github.com/aristotelesbr/lsd"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md]
  spec.bindir = "exe"
  spec.executables = ["lsd"]
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize", "~> 1.1"
  spec.add_dependency "terminal-table", "~> 3.0"
  spec.add_dependency "optparse", "~> 0.6.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.3"
  spec.metadata["rubygems_mfa_required"] = "true"
end
