# frozen_string_literal: true

module HOALife
  class Escalation < Resource
    include Resources::HasNestedResources

    self.base_path = '/escalations'

    has_nested_resources :violations
  end
end
