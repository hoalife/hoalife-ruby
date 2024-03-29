# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hoalife/version'

Gem::Specification.new do |spec|
  spec.name          = 'hoalife'
  spec.version       = HOALife::VERSION
  spec.authors       = ['Daniel Westendorf']
  spec.email         = ['daniel@prowestech.com']

  spec.summary       = 'Ruby API Client for the HOALife.com API'
  spec.description   = 'Interface for the HOALife.com HTTP API.'
  spec.homepage      = 'https://docs.hoalife.com'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hoalife/hoalife-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/hoalife/hoalife-ruby/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that
  # have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'zeitwerk', '~> 2.1'

  spec.add_development_dependency 'bundler', '> 2.3'
  spec.add_development_dependency 'listen', '~> 3.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 0.74'
  spec.add_development_dependency 'webmock', '~> 3.6'
end
