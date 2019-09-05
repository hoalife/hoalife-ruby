# frozen_string_literal: true

module HOALife
  class Error < StandardError; end

  # HTTP Errors
  class HTTPError < Error
    attr_reader :status, :headers, :details

    def initialize(status, headers, details)
      @status  = status
      @headers = headers
      @details = details

      super(status)
    end
  end

  class BadRequestError < HTTPError; end
  class UnauthorizedError < HTTPError; end
  class ForbiddenError < HTTPError; end
  class NotFoundError < HTTPError; end
  class RateLimitError < HTTPError; end

  class SigningMissmatchError < Error; end

  class UndefinedResourceError < Error; end
end
