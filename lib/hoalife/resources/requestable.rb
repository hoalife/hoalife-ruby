# frozen_string_literal: true

# Client request convenience methods
module HOALife::Resources::Requestable
  def make_request!(&blk)
    blk.call
  rescue HOALife::RateLimitError => e
    raise e unless HOALife.sleep_when_rate_limited

    sleep 1
    retry
  end
end
