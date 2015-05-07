require 'test_helper'
require 'sidekiq/testing'

class Redesign::ContactUsControllerTest < ActionController::TestCase
  setup do
    Sidekiq::Testing.inline!

    create_staff_user
    sign_in @staff_user

    @params = {
      name: 'Venu Keesari',
      email: 'keesari@unglobalcompact.org',
      organization: 'United Nations Global Compact',
      interest_ids: ['general_inquiry'],
      focus_ids: ['peace_rule_of_law'],
      comments: 'Hello!'
    }
  end

  context 'given post with valid params' do
    should 'send an email' do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post :create, redesign_contact_us_form: @params
      end

      email = ActionMailer::Base.deliveries.last

      assert_equal 'Contact Us Received from keesari@unglobalcompact.org', email.subject
      assert_equal 'contact@unglobalcompact.org', email.to[0] # TODO: Update with actual email.
      assert_match(/Venu Keesari/, email.body.to_s)
      assert_match(/keesari@unglobalcompact\.org/, email.body.to_s)
      assert_match(/United Nations Global Compact/, email.body.to_s)
      assert_match(/General Inquiry/, email.body.to_s)
      assert_match(/Peace Rule of Law/, email.body.to_s)
      assert_match(/Hello!/, email.body.to_s)

      assert_redirected_to redesign_contact_us_path
    end
  end

  context 'given post with invalid params' do
    should 'diesplay errors' do
      post :create, redesign_contact_us_form: @params.except(:name,:email,:comments)

      assert_select '#error_explanation', 1
    end
  end
end
