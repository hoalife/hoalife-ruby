# frozen_string_literal: true

module HOALife
  module Client
    # HTTP PUT requests
    class Put < Base
      private

      def request!
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          req = Net::HTTP::Put.new(uri, request_headers)

          req.body = @body

          http.request(req)
        end
      end
    end
  end
end
