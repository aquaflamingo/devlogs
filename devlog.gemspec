# frozen_string_literal: true

require_relative "lib/devlog/version"

Gem::Specification.new do |spec|
  spec.name          = "devlog"
  spec.version       = Devlog::VERSION
  spec.authors       = ["aquaflamingo"]
  spec.email         = ["16901597+aquaflamingo@users.noreply.github.com"]

  spec.summary       = "A command line utility to create and manage project management with a logs repository."
  spec.description   = "Create, manage and sync developer project logs"
  spec.homepage      = "http://github.com/aquaflamingo/devlog"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aquaflamingo/devlog"
  spec.metadata["changelog_uri"] = "https://github.com/aquaflamingo/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rsync", "~> 1.0", ">= 1.0.9"
  spec.add_dependency "thor", "~> 1.2.1"
  spec.add_dependency "tty-prompt", "~> 0.23.1"

  spec.add_development_dependency "pry", "~> 0.14.0"
end
