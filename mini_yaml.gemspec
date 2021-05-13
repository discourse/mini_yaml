# frozen_string_literal: true

require_relative "lib/mini_yaml/version"

Gem::Specification.new do |spec|
  spec.name          = "mini_yaml"
  spec.version       = MiniYaml::VERSION
  spec.authors       = ["Sam Saffron"]
  spec.email         = ["sam.saffron@gmail.com"]

  spec.summary       = "YAML editor and formatter"
  spec.description   = "YAML editor that preserves comments and formats YAML using opinionated rules"
  spec.homepage      = "https://discourse.org"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/discourse/mini_yaml"
  spec.metadata["changelog_uri"] = "https://github.com/discourse/mini_yaml/CHANGELOG.md"

  spec.files = Dir["README.md", "CHANGELOG.md", "LICENSE.txt", "lib/**/*", "bin/lint-yaml"]
  spec.executables   = "lint-yaml"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "rubocop"
end
