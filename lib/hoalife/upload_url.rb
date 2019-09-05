# frozen_string_literal: true

# :nodoc
class HOALife::UploadUrl < OpenStruct
  def url_expiration
    Time.parse(super)
  end
end
