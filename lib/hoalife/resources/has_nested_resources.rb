# frozen_string_literal: true

# Automatically follow links to related resources
module HOALife::Resources::HasNestedResources
  extend HOALife::Concern

  class_methods do
    attr_reader :has_nested_resources

    # rubocop:disable Naming/PredicateName
    def has_nested(key)
      @has_nested_resources ||= []

      @has_nested_resources.push(key)

      add_nested_resources_methods!(key)
    end
    # rubocop:enable Naming/PredicateName

    private

    def add_nested_resources_methods!(key)
      define_method key do
        raw_value = super()
        if raw_value.is_a?(Array)
          raw_value.collect do |value|
            HOALife::Resources::Collection.new(value['link']).all
          end.flatten
        else
          []
        end
      end
    end
  end
end
