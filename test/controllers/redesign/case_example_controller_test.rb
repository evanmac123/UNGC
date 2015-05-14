require 'test_helper'
require 'sidekiq/testing'

class Redesign::CaseExampleControllerTest < ActionController::TestCase
  setup do
    Sidekiq::Testing.inline!

    create_staff_user
    sign_in @staff_user

    @sector = create_sector
    @country = create_country

    @params = {
      company: 'Unspace',
      country_id: @country.id,
      sector_ids: [@sector.id],
      is_participant: true,
      file: fixture_file_upload('files/untitled.pdf', 'application/pdf')
    }
  end

  context 'given post with valid params' do
    should 'create a case example and send an email' do
      assert_difference ['CaseExample.count','ActionMailer::Base.deliveries.size'] do
        post :create, redesign_case_example_form: @params
      end

      case_example = CaseExample.last
      email = ActionMailer::Base.deliveries.last

      assert_equal @params[:company], case_example.company
      assert_equal @params[:country_id], case_example.country_id
      assert_equal @params[:sector_ids], case_example.sector_ids
      assert_equal @params[:is_participant], case_example.is_participant
      assert case_example.file.file?

      assert_equal 'Case Example Received from Unspace', email.subject
      assert_equal 'contact@unglobalcompact.org', email.to[0] # TODO: Update with actual email.
      assert_match /Unspace/, email.body.to_s
      assert_match /#{@country.name}/, email.body.to_s
      assert_match /#{@sector.name}/, email.body.to_s
      assert_match /Yes/, email.body.to_s
      assert_match /http:\/\/test.host#{Regexp.escape(case_example.file.url)}/, email.body.to_s

      assert_redirected_to redesign_case_example_path
    end
  end

  context 'given post without invalid params' do
    should 'display errors' do
      post :create, redesign_case_example_form: @params.except(:company, :country_id, :sector_ids, :file)

      assert_select '.errors-list li', 4
    end
  end

  context 'given post without a non participant params' do
    should 'be valid' do
      post :create, redesign_case_example_form: @params.merge(is_participant: false)
      case_example = CaseExample.last
      assert_select '#error_explanation ul li', 0
      assert_equal false, case_example.is_participant
    end
  end
end
