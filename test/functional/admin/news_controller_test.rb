require 'test_helper'

class Admin::NewsControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user
    end

    context "creating a new headline" do
      setup do
        @attributes = new_headline(:title => 'This is my headline').attributes
        assert_difference 'Headline.count', 1 do
          put :create, {:headline => @attributes}
        end
        @headline = Headline.find_by_title('This is my headline')
      end

      should "create the envet" do
        assert_redirected_to_index
        assert @headline
      end

      should "be pending approval" do
        assert @headline.pending?
      end

      context "then approve it" do
        setup do
          assert_no_difference 'Headline.count' do
            post :approve, {:id => @headline.id}
          end
          @headline.reload
        end

        should "approve the headline" do
          assert_redirected_to_index
          assert @headline.approved?
          assert_contains Headline.approved, @headline
        end

        context "but then revoke it" do
          setup do
            assert_no_difference 'Headline.count' do
              post :revoke, {:id => @headline.id}
            end
            @headline.reload
          end

          should "revoke approval of the headline" do
            assert_redirected_to_index
            assert @headline.revoked?
            assert_does_not_contain Headline.approved, @headline
          end
        end
      end
    end

    context "working with an existing headline" do
      setup do
        @headline = create_headline :title => 'This is my headline'
      end

      should "update" do
        assert_no_difference 'Headline.count' do
          post :update, {:id => @headline.id, :headline => @headline.attributes.merge(:title => 'Headline changed!')}
        end
        assert_equal 'Headline changed!', Headline.find(@headline.id).title
        assert_redirected_to_index
      end
    end
  end
end
