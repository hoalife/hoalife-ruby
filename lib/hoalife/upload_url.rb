# frozen_string_literal: true

module HOALife
  class UploadUrl < OpenStruct
    def url_expiration
      Time.parse(super)
    end
  end
end
