require 'test_helper'

class ParticipantSearch::FormTest < ActiveSupport::TestCase

  setup do
    @type_names = %w(city public sme)
    @type_names.map { |name| create_organization_type name: name }

    @intiiative_names = ['Water Mandate', 'Women\'s Empowerment Principles']
    @intiiative_names.map { |name| create_initiative name: name }

    @country_names = %w(Canada France Germany)
    @country_names.map { |name| create_country name: name }

    @subject = ParticipantSearch::Form.new
  end

  should "have organization_type_options" do
    assert_options @subject.organization_type_options, are_named: @type_names
  end

  should "have initiative_options" do
    assert_options @subject.initiative_options, are_named: @intiiative_names
  end

  should "have geography_options" do
    assert_options @subject.geography_options, are_named: @country_names
  end

  private

  def assert_options(collection, are_named: [])
    assert_equal are_named, collection.map(&:name)
  end

end

