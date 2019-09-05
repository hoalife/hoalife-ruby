# frozen_string_literal: true

require 'test_helper'
require 'openssl'
require 'ostruct'

module HOALife
  class MockResponse < OpenStruct
    def [](val)
      headers[val] || headers[val.to_s]
    end
  end

  class Client::BaseTest < HOALifeBaseTest
    API_KEY        = 'foo'
    SIGNING_SECRET = 'bar'
    API_VERSION    = 42

    def setup
      HOALife.config do |c|
        c.api_key        = API_KEY
        c.signing_secret = SIGNING_SECRET
        c.api_version    = API_VERSION
      end
    end

    def instance
      @instance ||= HOALife::Client::Base.new('https://example.com/foo')
    end

    def response
      @response ||= MockResponse.new(headers: headers, code: code, body: body)
    end

    def headers
      @headers ||= {}
    end

    def code
      @code ||= 200
    end

    def body
      @body ||= '{ "message": "Dynomite" }'
    end

    def body_signature
      digest = OpenSSL::Digest.new('sha256')

      OpenSSL::HMAC.hexdigest(
        digest, SIGNING_SECRET, body
      )
    end

    def test_api_version
      assert_equal "version=#{API_VERSION}", instance.send(:api_version)
    end

    def test_authorization_header
      assert_equal "Token #{API_KEY}", instance.send(:authorization_header)
    end

    def test_authorization_header_when_nil
      HOALife.api_key = nil

      assert_raises HOALife::Error do
        instance.send(:authorization_header)
      end
    end

    def test_generic_error
      @code    = '498'
      @body    = 'Boom'
      @headers = {
        'X-Request-Id' => '123'
      }

      error = instance.send(:generic_error, response)

      assert_equal error.dig('data', 'id'), headers['X-Request-Id']
      assert_equal error.dig('data', 'attributes', 'status'), code.to_i
      assert_equal error.dig('data', 'attributes', 'detail'), body
    end

    def test_verify_signature_matches
      @body      = 'Boom'
      digest     = OpenSSL::Digest.new('sha256')
      signature  = OpenSSL::HMAC.hexdigest(
        digest, SIGNING_SECRET, @body
      )

      @headers = {
        'X-Signature' => signature
      }

      assert_nil instance.send(:verify_signature!, response)
    end

    def test_verify_signature_does_not_match
      @body      = 'Boom'
      digest     = OpenSSL::Digest.new('sha256')
      signature  = OpenSSL::HMAC.hexdigest(
        digest, 'Bar', @body
      )

      @headers = {
        'X-Signature' => signature
      }

      assert_raises HOALife::SigningMissmatchError do
        instance.send(:verify_signature!, response)
      end
    end

    def test_401_status
      @code = '401'
      @body = '{}'
      assert_raises HOALife::UnauthorizedError do
        instance.send(:verify_successful_response!, response)
      end
    end

    def test_403_status
      @code = '403'
      @body = '{}'
      assert_raises HOALife::ForbiddenError do
        instance.send(:verify_successful_response!, response)
      end
    end

    def test_404_status
      @code = '404'
      @body = '{}'
      assert_raises HOALife::NotFoundError do
        instance.send(:verify_successful_response!, response)
      end
    end

    def test_429_status
      @code = '429'
      @body = '{}'
      assert_raises HOALife::RateLimitError do
        instance.send(:verify_successful_response!, response)
      end
    end

    def test_other_error_status
      @code = '500'
      @body = '{}'
      assert_raises HOALife::HTTPError do
        instance.send(:verify_successful_response!, response)
      end
    end

    def test_validate_response!
      @headers = {
        'X-Signature' => body_signature
      }

      instance.stub(:request!, response) do
        assert_equal response, instance.send(:validate_response!)
      end
    end

    def test_status
      @headers = {
        'X-Signature' => body_signature
      }

      instance.stub(:request!, response) do
        assert_equal response.code.to_i, instance.status
      end
    end

    def test_json
      @headers = {
        'X-Signature' => body_signature
      }

      instance.stub(:request!, response) do
        assert_equal JSON.parse(response.body), instance.json
      end
    end

    def test_response
      @headers = {
        'X-Signature' => body_signature
      }

      instance.stub(:request!, response) do
        assert_equal response, instance.response
      end
    end
  end
end
