require 'test_helper'

class ParticipantSearchFormTest < ActiveSupport::TestCase

  setup do
    @type_names = %w(city public sme)
    @types = @type_names.map { |name| create(:organization_type, name: name) }

    @intiiative_names = ['Water Mandate', 'Women\'s Empowerment Principles']
    @initiatives = @intiiative_names.map { |name| Initiative.find_by_name(name) ||  create(:initiative, name: name) }

    @country_names = %w(Canada France Germany)
    @countries = @country_names.map { |name| create(:country, name: name) }

    @subject = ParticipantSearchForm.new
    @subject.search_scope = facet_response
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

  def facet_response
    @facet_response ||= FakeFacetResponse.new.tap do |resp|
      resp.add(:country_id, @countries.map(&:id))
      resp.add(:organization_type_id, @types.map(&:id))
      resp.add(:initiative_ids, @initiatives.map(&:id))
    end
  end

end
