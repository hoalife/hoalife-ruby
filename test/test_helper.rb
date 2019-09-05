# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'hoalife'

require 'minitest/autorun'
require 'webmock/minitest'

class HOALifeBaseTest < Minitest::Test
end
