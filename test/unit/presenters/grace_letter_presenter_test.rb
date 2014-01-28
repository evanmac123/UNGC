require 'test_helper'

class GraceLettersPresenterTest < ActionController::TestCase

  setup do
    create_approved_organization_and_user
    grace_letter = create_cop_with_options(cop_type: 'grace')
    @it = GraceLetterPresenter.new(grace_letter, @organization_user)
  end

  should "have a created_at date" do
    assert_not_nil @it.created_at
  end

  should "have a start date" do
    assert_not_nil @it.starts_on
  end

  should "have an end date" do
    assert_not_nil @it.ends_on
  end

  should "not have files" do
    refute @it.has_files?, "expected not to have files."
  end

  should "have an organization" do
    assert_not_nil @it.organization
  end

  should "return to the dashboard " do
    assert_equal @it.dashboard_path(tab: :cops), "/admin/dashboard?tab=cops"
  end

  should "check for approval" do
    refute @it.can_approve?
  end

  should "check for reject" do
    refute @it.can_reject?
  end

  should "have an organization name" do
    assert_not_nil @it.organization_name
  end

end
