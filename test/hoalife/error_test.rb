# frozen_string_literal: true

require 'test_helper'

module HOALife
  class ErrorTest < HOALifeBaseTest
    def test_http_errors_include_status
      error = HOALife::HTTPError.new(38, nil, nil)

      assert_equal 38, error.status
    end

    def test_http_errors_include_headers
      headers = { a: 3 }
      error = HOALife::HTTPError.new(nil, headers, nil)

      assert_equal headers, error.headers
    end

    def test_http_errors_include_details
      details = { a: 3 }
      error = HOALife::HTTPError.new(nil, nil, details)

      assert_equal details, error.details
    end
  end
end
