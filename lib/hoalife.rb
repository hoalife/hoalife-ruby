# frozen_string_literal: true

require 'zeitwerk'
require 'hoal_inflector'

loader = Zeitwerk::Loader.for_gem
loader.inflector = HOALInflector.new
tests = "#{__dir__}/**/*_test.rb"
loader.ignore(tests)
# loader.log!

if ENV['DEV']
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
  @api_base    = ENV.fetch('HOALIFE_API_BASE', 'https://api.hoalife.com/api')
  @api_version = ENV.fetch('HOALIFE_API_VERSION', '1').to_i
  @api_key     = ENV['HOALIFE_API_KEY']
  @sleep_when_rate_limited = true

  class << self
    attr_accessor :api_key, :signing_secret, :api_base, :api_version,
                  :sleep_when_rate_limited

    # Support configuring with a block
    # HOALife.config do |config|
    #  config.api_key = "foo"
    # end
    # HOALife.api_key
    #   => "foo"
    def config
      yield self
    end
  end
end
