# frozen_string_literal: true

ACCOUNT_ATTRS = %i[
  mailing_street_2 external_id mailing_street_1 mailing_city mailing_state mailing_postal_code
].freeze
original_size = HOALife::Account.count
parent = HOALife::Account.where(organizational: true).first

csv = CSV.read(File.expand_path('properties.csv', __dir__), headers: true)

associations = csv.collect { |row| row["association_name"] }.uniq

associations.each.with_index do |association, i|
  attrs = {
    parent_id: parent.id, escalation_threshold: i + 1, repeat_violation_strategy: 'one_month_rolling_window',
    violation_lookback_period: 30, name: association
  }

  ACCOUNT_ATTRS.each do |attr|
    attrs[attr] = hex_of(association + attr.to_s)
  end

  account = HOALife::Account.create(attrs)
  assert(account.errors.nil?)
  refute(account.id.nil?)
end

refute_equal(original_size, HOALife::Account.reload.count)

associations.each.with_index do |association, i|
  assert_equal 1, HOALife::Account.where(name: association).count

  find_by_external_id = HOALife::Account.where(external_id: hex_of(association + 'external_id'))
  assert_equal 1, find_by_external_id.count

  found = find_by_external_id.first
  assert_equal i + 1, found.escalation_threshold
  assert_equal parent.id, found.parent_id

  found.external_id = hex_of(association + 'external_idCHANGED')
  assert(found.save)

  assert_equal 1, HOALife::Account.where(external_id: hex_of(association + 'external_idCHANGED')).count

  assert found.destroy
end

assert_equal(original_size, HOALife::Account.reload.count)
