# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aide/mq/version'

Gem::Specification.new do |spec|
  spec.name          = 'aide-mq'
  spec.version       = Aide::MQ::VERSION
  spec.authors       = ['David Nanry']
  spec.email         = ['dnanry']

  spec.summary       = 'A superset gem for the RabbitMQ `bunny` gem: utilities, ease of use,  and setup'
  spec.homepage      = 'https://github.com/aide-rb/aide-mq'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny',            '2.11'
  spec.add_dependency 'bunny-mock'
  spec.add_dependency 'connection_pool'
  spec.add_dependency 'dry-configurable', '~> 0.7'

  spec.add_development_dependency 'bundler',    '~> 1.16'
  spec.add_development_dependency 'pry-byebug', '~> 3.6'
  spec.add_development_dependency 'rake',       '~> 10.0'
  spec.add_development_dependency 'rspec',      '~> 3.0'
end
