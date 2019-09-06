# frozen_string_literal: true

# Client request convenience methods
module HOALife::Resources::Requestable
  def make_request!(&blk)
    blk.call
  rescue HOALife::RateLimitError => e
    raise e unless HOALife.sleep_when_rate_limited

    sleep HOALife.sleep_when_rate_limited.to_f
    retry
  end
end
