# frozen_string_literal: true

# :nodoc
class HOALife::Violation < HOALife::Resource
  include HOALife::Resources::HasNestedObject

  self.base_path = '/violations'

  has_nested_object :upload_urls, 'UploadUrl'
  has_nested_object :inspector, 'User'
end
