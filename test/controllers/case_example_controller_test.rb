require 'test_helper'
require 'sidekiq/testing'

class CaseExampleControllerTest < ActionController::TestCase
  setup do
    Sidekiq::Testing.inline!

    create_container path: '/take-action/action/share-story'

    create_staff_user
    sign_in @staff_user

    @sector = create_sector
    @sector2 = create_sector
    @country = create_country

    @params = {
      company: 'Unspace',
      country_id: @country.id,
      sector_ids: [@sector.id, @sector2.id],
      is_participant: true,
      magic: '3',
      file: fixture_file_upload('files/untitled.pdf', 'application/pdf')
    }
  end

  context 'form renders' do
    should 'have the required #id' do
      # see app/assets/javascripts/case-example-form.js
      get :new
      assert_select '#new_case_example_form'
      assert_select 'input[name="case_example_form[magic]"]'
    end
  end

  context 'given post with valid params' do
    should 'create a case example and send an email' do
      assert_difference ['CaseExample.count','ActionMailer::Base.deliveries.size'] do
        post :create, case_example_form: @params
      end

      case_example = CaseExample.last
      email = ActionMailer::Base.deliveries.last

      assert_equal @params[:company], case_example.company
      assert_equal @params[:country_id], case_example.country_id
      assert_equal @params[:sector_ids], case_example.sector_ids
      assert_equal @params[:is_participant], case_example.is_participant
      assert case_example.file.file?

      assert_equal 'Case Example Received from Unspace', email.subject
      assert_equal 'rmteam@unglobalcompact.org', email.to[0]
      assert_match /Unspace/, email.body.to_s
      assert_match /#{@country.name}/, email.body.to_s
      assert_match /#{@sector.name}/, email.body.to_s
      assert_match /#{@sector2.name}/, email.body.to_s
      assert_match /Yes/, email.body.to_s
      assert_match /http:\/\/test.host#{Regexp.escape(case_example.file.url)}/, email.body.to_s

      assert_redirected_to case_example_path
    end
  end

  context 'given post without invalid params' do
    should 'display errors' do
      post :create, case_example_form: @params.except(:company, :country_id, :sector_ids, :file)

      assert_select '.errors-list li', 4
    end

    should 'fail if magic value is not present' do
      post :create, case_example_form: @params.except(:magic)
      assert_select '.errors-list li', 1
    end
  end

  context 'given post without a non participant params' do
    should 'be valid' do
      post :create, case_example_form: @params.merge(is_participant: false)
      case_example = CaseExample.last
      assert_select '#error_explanation ul li', 0
      assert_equal false, case_example.is_participant
    end
  end
end
