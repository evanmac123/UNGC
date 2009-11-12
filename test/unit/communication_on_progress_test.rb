require 'test_helper'

class CommunicationOnProgressTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id, :title
  should_belong_to :organization
  should_have_and_belong_to_many :languages
  should_have_and_belong_to_many :countries
  should_have_and_belong_to_many :principles
  should_have_many :cop_answers
  should_have_many :cop_files
  
  context "given a COP" do
    setup do
      create_organization_and_user
      @cop = create_communication_on_progress(:organization_id => @organization.id)
    end
    
    should "change the organization's due date after it is approved" do
      assert_nil @organization.cop_due_on
      
      @cop.approve
      @organization.reload
      assert_equal 1.year.from_now.to_date, @organization.cop_due_on
    end
  end
end
