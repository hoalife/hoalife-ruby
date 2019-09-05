# frozen_string_literal: true

module HOALife
  module Resources
    # Client request convenience methods
    module Requestable
      def make_request!(&blk)
        blk.call
      rescue HOALife::RateLimitError => e
        raise e unless HOALife.sleep_when_rate_limited

        sleep 1
        retry
      end
    end
  end
end
