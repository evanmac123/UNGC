require 'test_helper'
require 'sidekiq/testing'

class ContactUsControllerTest < ActionController::TestCase
  setup do
    Sidekiq::Testing.inline!

    create(:container, path: '/about/contact')

    @params = {
      name: 'Venu Keesari',
      email: 'keesari@unglobalcompact.org',
      organization: 'United Nations Global Compact',
      magic: '3',
      interest_ids: ['general_inquiry', 'events'],
      focus_ids: ['peace', 'labour', 'poverty'],
      comments: 'Hello!'
    }
  end

  context 'form renders' do
    should 'have the required #id' do
      # see app/assets/javascripts/contact-form.js
      get :new
      assert_select '#new_contact_us_form'
      assert_select 'input[name="contact_us_form[magic]"]'
    end
  end

  context 'given post with valid params' do
    should 'send an email' do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post :create, contact_us_form: @params
      end

      email = ActionMailer::Base.deliveries.last

      assert_equal 'Contact Us Received from keesari@unglobalcompact.org', email.subject
      assert_equal 'info@unglobalcompact.org', email.to[0]
      assert_match(/Venu Keesari/, email.body.to_s)
      assert_match(/keesari@unglobalcompact\.org/, email.body.to_s)
      assert_match(/United Nations Global Compact/, email.body.to_s)
      assert_match(/General Inquiry/, email.body.to_s)
      assert_match(/Events/, email.body.to_s)
      assert_match(/Peace/, email.body.to_s)
      assert_match(/Hello!/, email.body.to_s)
      assert_equal email.to.count, 1

      assert_redirected_to contact_us_path
    end

    should 'send an email to the correct addresses, without duplication' do
      post :create, contact_us_form: @params

      email = ActionMailer::Base.deliveries.last

      assert email.to.include? 'info@unglobalcompact.org'
      assert_equal email.to.count, 1
    end

    should 'not include nils' do
      post :create, contact_us_form: @params.except(:interest_ids, :focus_ids)

      email = ActionMailer::Base.deliveries.last

      assert email.to.include? 'info@unglobalcompact.org'
      assert_equal email.to.count, 1
    end
  end

  context 'given post with invalid params' do
    should 'display errors' do
      post :create, contact_us_form: @params.except(:name,:email,:comments)

      assert_select '.errors-list', 1
    end

    should 'fail if magic value is not present' do
      post :create, contact_us_form: @params.except(:magic)
      assert_select '.errors-list li', 1
    end
  end
end
