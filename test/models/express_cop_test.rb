require 'test_helper'

class ExpressCopTest < ActiveSupport::TestCase

  setup do
    create_organization_type_sme
  end

  should 'create new Express COPs' do
    sme = create_organization(employees: 200)

    cop = ExpressCop.create!(
      organization: sme,
      endorses_ten_principles: true,
      covers_issue_areas: true,
      measures_outcomes: true,
    )

    assert cop.valid?
  end

  should 'have a valid factory' do
    assert create_express_cop.valid?
  end

  should 'have a default format' do
    cop = ExpressCop.new
    assert_equal 'express', cop.format
  end

end
