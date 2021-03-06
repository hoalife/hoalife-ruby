# frozen_string_literal: true

require 'test_helper'

class HOALife::Client::GetTest < HOALifeBaseTest
  def setup
    HOALife.config do |cfg|
      cfg.api_key = 'foo'
      cfg.signing_secret = nil
    end
  end

  def test_request!
    url      = 'https://example.com/foo'
    instance = HOALife::Client::Get.new(url)

    stub_request(:get, url).with(headers: instance.send(:request_headers))
                           .to_return(status: 200)

    assert_equal 200, instance.status
  end
end
