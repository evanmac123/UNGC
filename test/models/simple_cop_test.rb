require 'test_helper'

class SimpleCopTest < ActiveSupport::TestCase

  setup do
    create_organization_type_sme
  end

  should 'create new Simple COPs' do
    sme = create_organization(employees: 200)

    cop = SimpleCop.create!(
      organization: sme,
      endorses_ten_principles: true,
      covers_issue_areas: true,
      measures_outcomes: true,
    )

    assert cop.valid?
  end

  should 'have a valid factory' do
    assert create_simple_cop.valid?
  end

  should 'have a default format' do
    cop = SimpleCop.new
    assert_equal 'simple', cop.format
  end

end
