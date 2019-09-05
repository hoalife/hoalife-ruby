# frozen_string_literal: true

module HOALife
  module Client
    # HTTP Get requests
    class Get < Base
      private

      def request!
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          req = Net::HTTP::Get.new(uri, request_headers)

          http.request(req)
        end
      end
    end
  end
end
