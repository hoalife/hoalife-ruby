# frozen_string_literal: true

module HOALife
  module Client
    # HTTP DELETE requests
    class Delete < Base
      private

      def request!
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          req = Net::HTTP::Delete.new(uri, request_headers)

          http.request(req)
        end
      end
    end
  end
end
