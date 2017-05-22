require "test_helper"

class Admin::ActionPlatform::PlatformsControllerTest < ActionController::TestCase
	
	context "given nobody signed in" do
		
		should "#show should redirect to login" do
			platform = create(:action_platform_platform)
			
			get :show, id: platform.id
			
			assert_redirected_to '/login'
		end
		
		should "#new should redirect to login" do
			platform = create(:action_platform_platform)
			
			get :new
			
			assert_redirected_to '/login'
		end
		
		should "#index should redirect to login" do
			platform = create(:action_platform_platform)
			
			get :index
			
			assert_redirected_to '/login'
		end
		
	end
	
	context "given a staff user being signed in" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user
    end
		
		should "new" do
      get :new

      assert_response :success
      assert_not_nil assigns(:platform)
      assert_template :new
    end
		
		should "#index display all platforms" do
			platforms = create_list(:action_platform_platform, 4)
			
      get :index

      assert_response :success
      assert_template :index
      assert_equal platforms.count, assigns(:platforms).count
    end
		
		should "#show should respond and have the right platform set" do
			platform = create(:action_platform_platform)
			
			get :show, id: platform.id
			
			assert_response :ok
			assert_template :show
			assert_not_nil assigns(:platform)
			assert_equal platform, assigns(:platform)
		end
		
		should "#show lists the subscriptions for that platform " do
			platform = create(:action_platform_platform)
			subscriptions = create_list(:action_platform_subscription, 5, :platform => platform)
			
			another_platform = create(:action_platform_platform)
			other_subscriptions = create_list(:action_platform_subscription, 3, :platform => another_platform)
			
			
			get :show, id: platform.id
			
			assert_response :ok
			assert_template :show
			assert_not_nil assigns(:subscriptions)
			assert_equal platform, assigns(:platform)
			assert_equal subscriptions.count, assigns(:subscriptions).count
			
			
			get :show, id: another_platform.id
			
			assert_response :ok
			assert_template :show
			assert_not_nil assigns(:subscriptions)
			assert_equal another_platform, assigns(:platform)
			assert_equal other_subscriptions.count, assigns(:subscriptions).count
			
			
		end
		
		should "#create add a new platform" do
			name = 'A brand new platform'
			description = 'This is the description of the platform'
			slug = 'and the slug'
			post :create, {
				:action_platform_platform => {
					:name => name, 
					:description => description,
					:slug => slug
				}
			}
			platform = ActionPlatform::Platform.first
			assert_equal name, platform.name
			assert_equal description, platform.description
			assert_equal 'and the slug', platform.slug
			assert_redirected_to_index
		end
		
		should "#create does not create a platform on validation failure and sends you back to new" do
			name = 'A brand new platform'
			description = nil
			post :create, {:action_platform_platform => {:name => name, :description => description}}
			platform = ActionPlatform::Platform.first
			assert_nil platform
			assert_template :new
		end
		
		context "working with an existing platform" do
			setup do
				@platforms = [create(:action_platform_platform, :name => 'A new fantastic platform')]
			end
			
			should "#index display all platforms" do	
				get :index

				assert_response :success
				assert_template :index
				assert_equal @platforms.count, assigns(:platforms).count
			end
			
			should "#update updates the correct platform" do
				platform = @platforms.first
				old_description = platform.description
				old_slug = platform.slug
				
				new_name = 'Same platform, different name'
				put :update, :id => platform, :action_platform_platform => {:name => new_name}
				
				platform.reload
				assert_equal new_name, platform.name
				assert_equal old_description, platform.description
				assert_equal old_slug, platform.slug
				assert_redirected_to_index
				assert_equal @platforms.count, ActionPlatform::Platform.count
			end
			
			should "#destroy removes only the chosen platform" do
				@platform = @platforms.first
        assert_difference 'ActionPlatform::Platform.count', -1 do
          delete :destroy, id: @platform
        end
        assert_redirected_to_index
      end
			
			should "#destroy removes only the chosen platform and all of its subscriptions" do
				@platform = @platforms.first
				subscriptions = create_list(:action_platform_subscription, 5, :platform => @platform)
        assert_difference 'ActionPlatform::Platform.count', -1 do
          delete :destroy, id: @platform
        end
				assert_equal 0, ActionPlatform::Subscription.count
        assert_redirected_to_index
      end
		end
	end
end