# frozen_string_literal: true

require 'test_helper'

class HOALife::Client::DeleteTest < HOALifeBaseTest
  def setup
    HOALife.config do |cfg|
      cfg.api_base = 'https://example.com/foo'
      cfg.api_key = 'foo'
      cfg.signing_secret = nil
    end
  end

  def test_request!
    url      = 'https://example.com/foo'
    instance = HOALife::Client::Delete.new(url)

    stub_request(:delete, url).with(
      headers: instance.send(:request_headers)
    ).to_return(status: 202)

    assert_equal 202, instance.status
  end
end
