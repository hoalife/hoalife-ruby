# frozen_string_literal: true

# :nodoc
class HOALife::Violation < HOALife::Resource
  include HOALife::Resources::HasNestedObject
  include HOALife::Resources::Persistable

  self.base_path = '/violations'

  has_nested_object :upload_urls, 'UploadUrl'
  has_nested_object :inspector, 'User'

  def as_json
    h = super

    h.dig('data', 'relationships').merge!(
      'property' => { 'data' => { 'id' => property_id } },
      'ccr_violation_type' => { 'data' => { 'id' => ccr_violation_type_id } },
      'inspector' => { 'data' => { 'email' => inspector_email } }
    )

    h
  end
end
