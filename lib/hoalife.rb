# frozen_string_literal: true

require 'zeitwerk'
require 'hoal_inflector'

loader = Zeitwerk::Loader.new
loader.inflector = HOALInflector.new
loader.push_dir(File.join(__dir__))
tests = "#{__dir__}/**/*_test.rb"
loader.ignore(tests)
# loader.log!

if ENV['HOALIFE_RUBY_DEV']
  require 'listen'

  loader.enable_reloading
  Listen.to('lib') do
    loader.reload
  end.start
end

loader.setup

require 'hoalife/error'

# :nodoc
module HOALife
  class << self
    # Support configuring with a block
    # HOALife.config do |config|
    #  config.api_key = "foo"
    # end
    # HOALife.api_key
    #   => "foo"
    def config
      yield self
    end

    def thread_local_var(key, default_value = nil)
      Thread.current[key] = default_value

      define_singleton_method(key) do
        Thread.current[key]
      end

      define_singleton_method("#{key}=") do |value|
        Thread.current[key] = value
      end
    end
  end

  thread_local_var :api_key, ENV['HOALIFE_API_KEY']
  thread_local_var :signing_secret, ENV['HOALIFE_SIGNING_SECRET']

  thread_local_var :api_base, ENV.fetch('HOALIFE_API_BASE', 'https://api.hoalife.com/api')
  thread_local_var :api_version, ENV.fetch('HOALIFE_API_VERSION', '1').to_i
  thread_local_var :sleep_when_rate_limited, 10.0
end
