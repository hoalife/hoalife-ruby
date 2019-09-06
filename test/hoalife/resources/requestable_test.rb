# frozen_string_literal: true

require 'test_helper'

class HOALife::Resources::RequestableTest < HOALifeBaseTest
  def setup
    @object = Class.new
    @object.include(HOALife::Resources::Requestable)
  end

  def test_make_request_without_sleep
    HOALife.sleep_when_rate_limited = nil

    @object.new.make_request! do
      assert_raises HOALife::RateLimitError do
        raise HOALife::RateLimitError.new(nil, nil, nil)
      end
    end
  end

  def test_make_request_with_sleep
    HOALife.sleep_when_rate_limited = 0.0000000001
    count = 0

    @object.new.make_request! do
      count += 1
      raise HOALife::RateLimitError.new(nil, nil, nil) if count < 2
    end
  end
end
