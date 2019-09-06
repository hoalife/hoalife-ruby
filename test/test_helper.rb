# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'hoalife'
require 'hoalife/error'

require 'minitest/autorun'
require 'webmock/minitest'

class HOALifeBaseTest < Minitest::Test
  # Turn down the verbosity of warnings for a time
  def sssshhh(&blk)
    prev = $VERBOSE
    $VERBOSE = nil

    blk.call
    $VERBOSE = prev
  end
end
