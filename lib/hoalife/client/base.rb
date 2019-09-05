# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'json'

module HOALife
  module Client
    # Base class for all HTTP requests
    # Handles the implementation specific code of the API
    class Base
      def initialize(url, body = nil)
        @url  = url
        @body = body
      end

      def status
        @status ||= response.code.to_i
      end

      def json
        @json ||= JSON.parse(response.body)
      end

      def response
        @response ||= validate_response!
      end

      private

      def request!
        raise 'Not implemented'
      end

      def uri
        @uri ||= URI(@url)
      end

      def request_headers
        {
          'Authorization' => authorization_header,
          'ACCEPT' => api_version,
          'Content-Type' => 'application/vnd.api+json'
        }
      end

      def validate_response!
        response = request!

        verify_successful_response!(response)

        verify_signature!(response) unless HOALife.signing_secret.nil?

        response
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def verify_successful_response!(resp)
        headers = resp.each_header.to_h
        body    = resp.body
        code    = resp.code.to_i

        case code
        when 400
          raise BadRequestError.new(code, headers, body)
        when 401
          raise UnauthorizedError.new(code, headers, body)
        when 403
          raise ForbiddenError.new(code, headers, body)
        when 404
          raise NotFoundError.new(code, headers, body)
        when 429
          raise RateLimitError.new(code, headers, body)
        when 400..600
          raise HTTPError.new(code, headers, generic_error(resp))
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def verify_signature!(resp)
        digest    = OpenSSL::Digest.new('sha256')
        signature = OpenSSL::HMAC.hexdigest(
          digest, HOALife.signing_secret, resp.body
        )

        raise SigningMissmatchError if signature != resp['X-Signature']
      end

      def api_version
        return nil if HOALife.api_version.nil?

        "version=#{HOALife.api_version}"
      end

      def authorization_header
        raise Error, 'No API Key specified' if HOALife.api_key.nil?

        "Token #{HOALife.api_key}"
      end

      def generic_error(resp)
        hash = {
          'data' => {
            'id' => resp['X-Request-Id'], 'type' => 'error',
            'attributes' => {}
          }
        }

        JSON.parse(resp.body)
      rescue JSON::ParserError
        {
          'data' => {
            'id' => resp['X-Request-Id'], 'type' => 'error',
            'attributes' => {
              'id' => resp['X-Request-Id'], 'title' => 'HTTP Error',
              'status' => resp.code.to_i, 'detail' => resp.body
            }
          }
        }
      end
    end
  end
end
