# frozen_string_literal: true

articles = [
  {
    article: 1,
    title: 'Exterior Maintenance',
    violation_types_attributes: [
      {
        title: 'Mildew on home',
        resolution_step: 'Please pressure wash your home in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Faded shutters',
        resolution_step: 'Please paint your shutters in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Siding damaged',
        resolution_step: 'Please repair/replace the damaged siding in the next 20 day',
        days_to_cure: 20
      },
      {
        title: 'Shutter(s) missing/damaged',
        resolution_step: 'Please repair/replace the missing/damaged shutter(s) in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Mailbox is damaged',
        resolution_step: 'Please repair/replace the damaged mailbox in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Mailbox needs to be painted',
        resolution_step: 'Please paint your mailbox in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Garage door damaged',
        resolution_step: 'Please repair/replace the garage door in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Fence damaged',
        resolution_step: 'Please repair the damaged fence in the next 20 days',
        days_to_cure: 20
      },
      {
        title: 'Trim on home needs to be painted',
        resolution_step: 'Please paint the trim on your home in the next 20 days',
        days_to_cure: 20
      }
    ]
  },
  {
    article: 2,
    title: 'ARC',
    violation_types_attributes: [
      {
        title: 'Unapproved structure',
        resolution_step: 'Please submit an ARC form in the next 10 days',
        days_to_cure: 10
      }
    ]
  },
  {
    article: 3,
    title: 'Improper Storage',
    violation_types_attributes: [
      {
        title: 'Basketball goal',
        resolution_step: 'Please properly store your basketball goal when not in use',
        days_to_cure: nil
      },
      {
        title: 'Garbage can(s) in view from street',
        resolution_step: "Please store your garbage can(s) from the view of the street on days not \
                          deemed for pickup",
        days_to_cure: nil
      },
      {
        title: 'Improperly stored item(s) around home',
        resolution_step: 'Please properly store all item(s) in the next 5 days',
        days_to_cure: 5
      }
    ]
  },
  {
    article: 4,
    title: 'Vehicles',
    violation_types_attributes: [
      {
        title: 'Vehicle(s) parked in grass',
        resolution_step: 'Please refrain from parking in the grassy areas of the community',
        days_to_cure: nil
      },
      {
        title: 'Inoperable vehicle at residence',
        resolution_step: 'Please repair/properly register your vehicle in the next 10 days',
        days_to_cure: 10
      },
      {
        title: 'Trailer at residence',
        resolution_step: 'Please remove the trailer from the community in the next 5 days',
        days_to_cure: 5
      },
      {
        title: 'Boat at residence',
        resolution_step: 'Please remove the boat from the community in the next 5 days',
        days_to_cure: 5
      }
    ]
  },
  {
    article: 5,
    title: 'Lawn Maintenance',
    violation_types_attributes: [
      {
        title: 'High grass',
        resolution_step: 'Please mow your lawn in the next 7 days',
        days_to_cure: 7
      },
      {
        title: 'Weeds in lawn',
        resolution_step: 'Please treat the weeds in your lawn in the next 15 days',
        days_to_cure: 15
      },
      {
        title: 'Weeds in landscaping bed(s)',
        resolution_step: 'Please treat the weeds in your landscaping bed(s) in the next 15 days',
        days_to_cure: 15
      },
      {
        title: 'Bare spot(s) in lawn',
        resolution_step: 'Please treat the bare spot(s) in your lawn in the next 15 days',
        days_to_cure: 15
      },
      {
        title: 'Rut in lawn',
        resolution_step: 'Please fill in the rut in your lawn in the next 15 days',
        days_to_cure: 15
      },
      {
        title: 'Overgrown Shrub(s)',
        resolution_step: 'Please trim your shrub(s) in the next 10 days',
        days_to_cure: 10
      }
    ]
  }
]

parent = HOALife::Account.where(organizational: true).first
account = HOALife::Account.create(name: 'Article & VT test', parent_id: parent.id)

articles.each do |article|
  record = HOALife::CCRArticle.create(
    article: article[:article], title: article[:title], description: 'Description here!',
    account_id: account.id
  )

  assert(record.errors.nil?)

  article[:violation_types_attributes].each.with_index do |vt_attrs, i|
    assert(HOALife::CCRViolationType.create(vt_attrs.merge(ccr_article_id: record.id, external_id: i)))
  end

  article_violation_types = HOALife::CCRViolationType.where(ccr_article_id: record.id).tap(&:all)
  assert_equal article[:violation_types_attributes].size, article_violation_types.count

  article[:violation_types_attributes].each.with_index do |_vt, i|
    violation_type = HOALife::CCRViolationType.where(external_id: i).first
    assert(violation_type.destroy)
  end

  assert(record.destroy)
end

assert(account.destroy)
