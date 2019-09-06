# frozen_string_literal: true

require 'test_helper'

class HOALife::Client::PutTest < HOALifeBaseTest
  def setup
    HOALife.config do |cfg|
      cfg.api_key = 'foo'
      cfg.signing_secret = nil
    end
  end

  def test_request!
    url      = 'https://example.com/foo'
    body     = '{"foo": "bar"}'
    instance = HOALife::Client::Put.new(url, body)

    stub_request(:put, url).with(
      headers: instance.send(:request_headers), body: body
    ).to_return(status: 200)

    assert_equal 200, instance.status
  end
end
