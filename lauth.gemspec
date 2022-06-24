# frozen_string_literal: true

require_relative "lib/lauth/version"

Gem::Specification.new do |spec|
  spec.name = "lauth"
  spec.version = Lauth::VERSION
  spec.authors = ["Greg Kostin"]
  spec.email = ["gkostin@umich.edu"]

  spec.summary = "Library Authorization."
  spec.description = "Michigan Library Authorization Command Line Client (lauth) and API Server (lauthd)."
  spec.homepage = "https://github.com/mlibrary/lauth"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mlibrary/lauth"
  spec.metadata["changelog_uri"] = "https://github.com/mlibrary/lauth/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "gli"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "hanami-api"
  spec.add_dependency "puma"
  spec.add_dependency "rom"
  spec.add_dependency "rom-sql"
  spec.add_dependency "rom-http"
  spec.add_dependency "mysql2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
