# frozen_string_literal: true

require 'test_helper'

class HOALife::Client::PostTest < HOALifeBaseTest
  def setup
    HOALife.config do |cfg|
      cfg.api_base = 'https://example.com/foo'
      cfg.api_key = 'foo'
      cfg.signing_secret = nil
    end
  end

  def test_request!
    url      = 'https://example.com/foo'
    body     = '{"foo": "bar"}'
    instance = HOALife::Client::Post.new(url, body)

    stub_request(:post, url).with(
      headers: instance.send(:request_headers), body: body
    ).to_return(status: 201)

    assert_equal 201, instance.status
  end
end
