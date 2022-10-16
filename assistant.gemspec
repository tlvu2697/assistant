# frozen_string_literal: true

require_relative 'lib/assistant/version'

Gem::Specification.new do |spec|
  spec.name          = 'assistant'
  spec.version       = Assistant::VERSION
  spec.authors       = ['Le-Vu Tran']
  spec.email         = ['vu.tran@employmenthero.com']

  spec.summary       = 'Write a short summary, because RubyGems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.homepage      = 'https://gem.vutran.cyou'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host'] = "Set to 'https://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/tlvu2697/assistant'
  spec.metadata['changelog_uri'] = 'https://raw.githubusercontent.com/tlvu2697/assistant/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['assistant']
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_runtime_dependency 'clipboard', '~> 1.3.6'
  spec.add_runtime_dependency 'dry-cli', '~> 0.6'
  spec.add_runtime_dependency 'dry-monads', '~> 1.3.5'
  spec.add_runtime_dependency 'httparty', '~> 0.20.0'
  spec.add_runtime_dependency 'pastel', '~> 0.8.0'
  spec.add_runtime_dependency 'tty-command', '~> 0.10.1'
  spec.add_runtime_dependency 'tty-config', '~> 0.5.1'
  spec.add_runtime_dependency 'tty-file', '~> 0.10.0'
  spec.add_runtime_dependency 'tty-logger', '~> 0.6.0'
  spec.add_runtime_dependency 'tty-platform', '~> 0.3.0'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.23.1'
  spec.add_runtime_dependency 'tty-spinner', '~> 0.9.0'

  spec.add_development_dependency 'byebug', '~> 11.1.3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.7'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
