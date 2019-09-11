# frozen_string_literal: true

require 'test_helper'

class HOALifeTest < HOALifeBaseTest
  def test_config_block
    HOALife.config do |c|
      c.api_key = 'foo'
    end

    assert_equal 'foo', HOALife.api_key
  end

  def test_thread_safe_config
    threads = []

    100.times do |i|
      threads << Thread.new do
        HOALife.config do |c|
          c.api_key = "foo#{i}"
        end

        HOALife.signing_secret = "bar#{i}"
        puts "assigned foo#{i}, bar#{i}"

        sleep rand

        assert_equal "foo#{i}", HOALife.api_key
        assert_equal "bar#{i}", HOALife.signing_secret
        puts "asserted foo#{i}, bar#{i}"
      end
    end

    threads.each(&:join)
  end
end
