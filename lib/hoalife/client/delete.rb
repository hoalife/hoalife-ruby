# frozen_string_literal: true

# HTTP DELETE requests
class HOALife::Client::Delete < HOALife::Client::Base
  private

  def request!
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Delete.new(uri, request_headers)

      http.request(req)
    end
  end
end
