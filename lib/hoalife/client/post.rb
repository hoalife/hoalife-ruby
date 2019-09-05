# frozen_string_literal: true

module HOALife
  module Client
    # HTTP POST requests
    class Post < Base
      private

      def request!
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          req = Net::HTTP::Post.new(uri, request_headers)

          req.body = @body

          http.request(req)
        end
      end
    end
  end
end
