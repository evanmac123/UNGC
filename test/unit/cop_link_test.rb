require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should_validate_presence_of :attachment_type
  should_belong_to :communication_on_progress
  should_belong_to :language
  
  context "given a new COP" do
    setup do
      create_organization_and_user
      @cop = create_cop(@organization.id)
      @language = create_language
    end

    should "not save the COP if the URL is invalid" do
      @cop.cop_links.create(:url => 'http://bad_link', :attachment_type => 'cop', :language_id => @language.id)
      assert !@cop.valid?
    end
    
    should "save the COP if the URL is valid" do
      @cop.cop_links.create(:url => 'http://goodlink.com/', :attachment_type => 'cop', :language_id => @language.id)
      assert @cop.valid?
    end
    
    should "save the COP if the URL is blank" do
      @cop.cop_links.create(:url => '', :attachment_type => 'cop', :language_id => @language.id)
      assert @cop.valid?
    end
    
  end
   
end