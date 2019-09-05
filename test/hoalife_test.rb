# frozen_string_literal: true

require 'test_helper'

class HOALifeTest < HOALifeBaseTest
  def test_config_block
    HOALife.config do |c|
      c.api_key = 'foo'
    end

    assert_equal 'foo', HOALife.api_key
  end
end
