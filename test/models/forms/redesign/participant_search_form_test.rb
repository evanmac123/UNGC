require 'test_helper'

class Redesign::ParticipantSearchFormTest < ActiveSupport::TestCase

  setup do
    @type_names = %w(city public sme)
    @types = @type_names.map { |name| create_organization_type name: name }

    @intiiative_names = ['Water Mandate', 'Women\'s Empowerment Principles']
    @initiatives = @intiiative_names.map { |name| create_initiative name: name }

    @country_names = %w(Canada France Germany)
    @countries = @country_names.map { |name| create_country name: name }

    @subject = Redesign::ParticipantSearchForm.new
    @subject.search_scope = stub(facets:{
      country_id: stub(keys: @countries.map(&:id)),
      organization_type_id: stub(keys: @types.map(&:id)),
      initiative_ids: stub(keys: @initiatives.map(&:id)),
    })
  end

  should "have organization_type_options" do
    assert_has_options @subject.organization_type_filter, @type_names
  end

  should "have initiative_options" do
    assert_has_options @subject.initiative_filter, @intiiative_names
  end

  should "have geography_options" do
    assert_has_options @subject.country_filter, @country_names
  end

  private

  def assert_has_options(filter, named)
    assert_equal named, filter.options.map(&:name)
  end

end

