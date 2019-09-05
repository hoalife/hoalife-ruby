# frozen_string_literal: true

# HTTP PUT requests
class HOALife::Client::Put < HOALife::Client::Base
  private

  def request!
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Put.new(uri, request_headers)

      req.body = @body

      http.request(req)
    end
  end
end
