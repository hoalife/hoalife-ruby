# frozen_string_literal: true

# :nodoc
class HOALife::CCRArticle < HOALife::Resource
  include HOALife::Resources::Persistable

  self.base_path = '/ccr_articles'

  def as_json
    h = super

    h.dig('data', 'relationships').merge!(
      'account' => { 'data' => { 'id' => account_id } }
    )

    h
  end
end
