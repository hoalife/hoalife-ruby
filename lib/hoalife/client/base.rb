# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'json'

# Base class for all HTTP requests
# Handles the implementation specific code of the API
class HOALife::Client::Base
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

  # rubocop:disable Metrics/MethodLength
  def verify_successful_response!(resp)
    headers = resp.each_header.to_h
    body    = resp.body
    code    = resp.code.to_i

    case code
    when 400
      raise HOALife::BadRequestError.new(code, headers, body)
    when 401..403
      auth_error(headers, body, code)
    when 404..429
      http_error(headers, body, code)
    when 400..600
      raise HOALife::HTTPError.new(code, headers, generic_error(resp))
    end
  end
  # rubocop:enable Metrics/MethodLength

  def auth_error(headers, body, code)
    case code
    when 401
      raise HOALife::UnauthorizedError.new(code, headers, body)
    when 403
      raise HOALife::ForbiddenError.new(code, headers, body)
    end
  end

  def http_error(headers, body, code)
    case code
    when 404
      raise HOALife::NotFoundError.new(code, headers, body)
    when 429
      raise HOALife::RateLimitError.new(code, headers, body)
    end
  end

  def verify_signature!(resp)
    digest    = OpenSSL::Digest.new('sha256')
    signature = OpenSSL::HMAC.hexdigest(
      digest, HOALife.signing_secret, resp.body
    )

    raise HOALife::SigningMissmatchError if signature != resp['X-Signature']
  end

  def api_version
    return nil if HOALife.api_version.nil?

    "application/vnd.api+json; version=#{HOALife.api_version}"
  end

  def authorization_header
    raise HOALife::Error, 'No API Key specified' if HOALife.api_key.nil?

    "Token #{HOALife.api_key}"
  end

  def generic_error(resp)
    JSON.parse(resp.body)
  rescue JSON::ParserError
    { 'data' => {
      'id' => resp['X-Request-Id'], 'type' => 'error',
      'attributes' => {
        'id' => resp['X-Request-Id'], 'title' => 'HTTP Error',
        'status' => resp.code.to_i, 'detail' => resp.body
      }
    } }
  end
end
