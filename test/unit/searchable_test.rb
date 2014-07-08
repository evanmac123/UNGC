require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  context "given some pages that have already been indexed by searchable" do
    setup do
      @page1 = create_page
      @page2 = create_page
      @page3 = create_page title: 'Page 3 here'
      Searchable.index_pages
    end

    context "and changes are made" do
      setup do
        assert @prev_max = Searchable.find(:all, select: "MAX(last_indexed_at) as max").first.try(:max)
        sleep(2) { donothing = true; justwaiting = "for the timestamps to be sufficiently different" }
        @page4 = create_page title: 'Page 4 here'
        @page3.title = "I am new"
        @page3.save
      end

      should "only index new or updated pages" do
        Searchable.index_new_or_updated
        newish = Searchable.find(:all, conditions: ["last_indexed_at > ?", @prev_max])
        assert_same_elements [@page4.title, @page3.title], newish.map(&:title)
      end

      should "delete the searchable after the page is deleted" do
        assert_difference 'Searchable.count', -1 do
          @page2.destroy
        end
      end
    end
  end

  context "Indexing Events" do

    setup do
      @unapproved = create_searchable_event
      @approved = create_searchable_event
      @approved.approve!
      Searchable.index_events
      @searchable = Searchable.first
    end

    should "include approved events" do
      assert_contains Searchable.scoped.map(&:title), @approved.title
    end

    should "not include unapproved events" do
      assert_does_not_contain Searchable.scoped.map(&:title), @unapproved.title
    end

    should "include title" do
      assert_equal @approved.title, @searchable.title
    end

    should "include location" do
      assert_match Regexp.new(@approved.location), @searchable.content
    end

    should "include the url to an event" do
      assert_match /^\/events\//, @searchable.url
    end

    should "have an event document_type" do
      assert_equal "Event", @searchable.document_type
    end

    should "delete the searchable after the event is deleted" do
      assert_difference 'Searchable.count', -1 do
        @approved.destroy
      end
    end
  end

  context "Indexing Headlines" do
    setup do
      @headline = create_headline
      @headline.approve!
      Searchable.index_headlines
      @searchable = Searchable.first
    end

    should "have indexed the headline" do
      assert_not_nil @searchable
    end

    should "have the correct document_type" do
      assert_equal 'Headline', @searchable.document_type
    end

    should "delete the searchable after the headline is deleted" do
      assert_difference 'Searchable.count', -1 do
        @headline.destroy
      end
    end
  end

  context "Indexing Organizations" do
    setup do
      @organization = create_organization(
        organization_type:create_organization_type,
        active:true,
        participant:true,
      )
      @organization.approve!
      Searchable.index_organizations
      @searchable = Searchable.first
    end

    should "have indexed the organization" do
      assert_not_nil @searchable
    end

    should "have the correct document_type" do
      assert_equal 'Participant', @searchable.document_type
    end

    should "not add a new record after the organization is renamed" do
      @organization.update_attribute(:name, "new name")
      assert_no_difference 'Searchable.count' do
        Searchable.index_organizations
      end
    end

    should "delete the searchable after the organization is removed" do
      assert_difference 'Searchable.count', -1 do
        @organization.destroy
      end
    end

  end

  context "Indexing Communications_on_progress" do
    setup do
      type = create_organization_type(name: 'Company', type_property: OrganizationType::BUSINESS)
      organization = create_organization(organization_type: type)
      @cop = create_communication_on_progress(organization: organization)
      Searchable.index_communications_on_progress
      @searchable = Searchable.first
    end

    should "have indexed the communication_on_progress" do
      assert_not_nil @searchable
    end

    should "have the correct document_type" do
      assert_equal 'CommunicationOnProgress', @searchable.document_type
    end

    should "delete the searchable after the communications_on_progres is deleted" do
      assert_difference 'Searchable.count', -1 do
        @cop.destroy
      end
    end
  end

  context "Indexing Resources" do
    setup do
      @resource = create_resource
      @resource.approve!
      Searchable.index_resources
      @searchable = Searchable.first
    end

    should "have indexed the resource" do
      assert_not_nil @searchable
    end

    should "have the correct document_type" do
      assert_equal 'Resource', @searchable.document_type
    end

    should "delete the searchable after the resource is deleted" do
      assert_difference 'Searchable.count', -1 do
        @resource.destroy
      end
    end
  end

end
