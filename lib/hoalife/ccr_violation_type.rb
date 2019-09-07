# frozen_string_literal: true

# :nodoc
class HOALife::CCRViolationType < HOALife::Resource
  include HOALife::Resources::Persistable

  self.base_path = '/ccr_violation_types'

  def as_json
    h = super

    h.dig('data', 'relationships').merge!(
      'ccr_article' => { 'data' => { 'id' => ccr_article_id } }
    )

    h
  end
end
