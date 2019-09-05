# frozen_string_literal: true

module HOALife
  class Violation < Resource
    include Resources::HasNestedObject

    self.base_path = '/violations'

    has_nested_object :upload_urls, "UploadUrl"
    has_nested_object :inspector, "User"
  end
end
