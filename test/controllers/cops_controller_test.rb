require 'test_helper'

class CopsControllerTest < ActionController::TestCase
 test 'should get index' do
   create(:container, path: '/participation/report/cop/create-and-submit')

   get :index
   assert_response :success
   assert_not_nil assigns(:page)
 end

 should "link to a COP" do
   expected = "/participation/report/cop/create-and-submit/learner/#{cop.id}"
   cop_path = show_cops_path(differentiation: cop.differentiation_level_with_default, id: cop.id)
   assert_equal expected, cop_path
 end

 should "link to a COP without a type" do
   # there are many existing COPs that lack a value for cop_type
   cop = cop(cop_type: nil)
   expected = "/participation/report/cop/create-and-submit/learner/#{cop.id}"
   cop_path = show_cops_path(differentiation: cop.differentiation_level_with_default, id: cop.id)
   assert_equal expected, cop_path
 end

 test "should get active" do
   create(:container, path: '/participation/report/cop/create-and-submit/active')

   get :active
   assert_response :success
   assert_not_nil assigns(:page)
 end

 test "should get advanced" do
   create(:container, path:'/participation/report/cop/create-and-submit/advanced')

   get :advanced
   assert_response :success
   assert_not_nil assigns(:page)
 end

 test "should get expelled" do
   create(:container, path:'/participation/report/cop/create-and-submit/expelled')

   get :expelled
   assert_response :success
   assert_not_nil assigns(:page)
 end

 test "should get learner" do
   create(:container, path: '/participation/report/cop/create-and-submit/learner')

   get :learner
   assert_response :success
   assert_not_nil assigns(:page)
 end

 test "should get non-communicating" do
   create(:container, path: '/participation/report/cop/create-and-submit/non-communicating')

   get :non_communicating
   assert_response :success
   assert_not_nil assigns(:page)
 end

 test "should get submitted coe" do
  create(:container, path: '/participation/report/coe/create-and-submit/submitted-coe')

  get :submitted_coe
  assert_response :success
  assert_not_nil assigns(:page)
 end

 context "given a request for feeds/cops" do
   setup do
     get :feed, :format => 'atom'
   end

   should "display the atom feed" do
     assert_template 'cops/feed'
   end
 end

 context "#show" do

   setup do
     create(:container, path: '/participation/report')
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
       assert_response :not_found
     end
   end

   context "given a differentiation style COP" do
     setup do
       create_approved_organization_and_user
       create_cop_with_options({
         cop_type: 'basic',
         created_at: CommunicationOnProgress::START_DATE_OF_DIFFERENTIATION + 1.day,
       })
     end

     should "display public differentiation style partial" do
       get :show, :organization_id => @organization.id,
                  :id              => @cop.id
       assert_template :partial => '_show_differentiation_style_public'
     end
   end

 end

 private

 def cop(attrs = {})
   @org_type ||= create(:organization_type)
   @org ||= create(:organization)
   @cop ||= create(:communication_on_progress, attrs.reverse_merge(cop_type: 'basic'))
 end

 def setup_organization
   create_organization_and_user
   @organization.approve!
   create_principle_areas
   sign_in @organization_user
 end


 def create_cop_with_differentiation(differentiation_level)
   cop = create_cop(@organization.id)
   cop.update_attribute(:differentiation, differentiation_level)
   cop.save!
   assert_equal cop.differentiation, differentiation_level
   cop
 end

end
