require 'test_helper'

class CopsControllerTest < ActionController::TestCase

  context "given a request for feeds/cops" do
    setup do
      get :feed, :format => 'atom'
    end

    should "display the atom feed" do
      assert_template 'cops/feed'
    end
  end

  context "given COP created in 2008" do
    setup do
      setup_organization
      @cop = create_cop(@organization.id, :created_at => Date.parse('31-12-2008'))
    end

    should "display the legacy style" do
      get :show, :id => @cop.id
      assert_equal true, @cop.is_legacy_format?
      assert_template :partial => '_show_legacy_style'
    end
  end

  context "given a COP created in 2010" do
    setup do
      setup_organization
      @cop = create_cop(@organization.id, :created_at => Date.parse('06-06-2010'))
    end

    should "display the new style" do
      get :show, :id => @cop.id
      assert_equal true, @cop.is_new_format?
      assert_template :partial => '_show_new_style'
    end
  end

  context "given a COP created in 2011" do
    setup do
      setup_organization
      @cop = create_cop(@organization.id)
    end

    should "display the differentation style for the public" do
      get :show, :id => @cop.id
      assert_equal true, @cop.is_differentiation_program?
      assert_template :partial => '_show_differentiation_style_public'
    end
  end

  context "given a COP that doesn't exist" do
    setup do
      setup_organization
      @cop = create_cop(@organization.id)
    end

    should "redirect to COP path" do
      get :show, :id => 123456789
      assert_redirected_to DEFAULTS[:cop_path]
    end
  end

  context "given a differentiation style COP" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options({
        type: 'basic',
        created_at: CommunicationOnProgress::START_DATE_OF_DIFFERENTIATION + 1.day,
      })
      sign_in @organization_user
    end

    should "display public differentiation style partial" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_template :partial => '_show_differentiation_style_public'
    end
  end

private

  def setup_organization
    create_organization_and_user
    @organization.approve!
    create_principle_areas
    sign_in @organization_user
  end

end
