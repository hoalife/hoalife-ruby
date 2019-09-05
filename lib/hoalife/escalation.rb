# frozen_string_literal: true

# :nodoc
class HOALife::Escalation < HOALife::Resource
  include HOALife::Resources::HasNestedResources

  self.base_path = '/escalations'

  has_nested_resources :violations
end
