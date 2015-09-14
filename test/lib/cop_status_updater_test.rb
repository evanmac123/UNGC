require 'test_helper'

class CopStatusUpdaterTest < ActiveSupport::TestCase

  setup do
    create_organization_type(name: 'Company') # needed for create_organization
    @status_updater = CopStatusUpdater.new(logger, mailer)
  end

  context 'an active business participant with a COP due' do

    should 'be moved to non-communicating status' do
      assert about_to_become_noncommunicating.active?
      @status_updater.update_all
      assert about_to_become_noncommunicating.reload.noncommunicating?
    end

  end

  context 'a non-communicating business with a very late COP' do

    should 'be delisted' do
      assert about_to_become_delisted.noncommunicating?
      @status_updater.update_all
      assert about_to_become_delisted.reload.delisted?
    end

  end

  context 'logging' do

    setup do
      # create the two participants
      about_to_become_noncommunicating
      about_to_become_delisted

      @updater = CopStatusUpdater.new(logger, mailer)
    end

    should 'not have logged any errors' do
      logger.expects(:error).never
      @updater.update_all
    end

    context "non-communicating" do

      setup do
        @slug = "#{about_to_become_noncommunicating.id}: #{about_to_become_noncommunicating.name}"
      end

      should 'log the acitve -> non-communicating phase' do
        logger.expects(:info).with("Running move_active_organizations_to_noncommunicating")
        @updater.update_all
      end

      should 'log the newly non-communicating participant' do
        logger.expects(:info).with("#{@slug} is Non-Communicating")
        @updater.update_all
      end

    end

    context "delisted" do

      setup do
        @slug = "#{about_to_become_delisted.id}:#{about_to_become_delisted.name}"
      end

      should 'log the non-communicating -> delisted phase' do
        logger.expects(:info).with("Running move_noncommunicating_organizations_to_delisted")
        @updater.update_all
      end

      should 'log the newly delisted participant' do
        logger.expects(:info).with("Delisted #{@slug}")
        @updater.update_all
      end

      should 'log that the newly delisted participant was emailed' do
        logger.expects(:info).with("emailed delisted #{@slug}")
        @updater.update_all
      end

    end

  end

  context 'emailing' do

    should 'send an email to delisted participants' do
      updater = CopStatusUpdater.new(logger, mailer)

      mailer.expects(:delisting_today)
        .with(about_to_become_delisted)
        .returns(stub(:deliver))
        .once

      updater.update_all
    end

  end

  private

  def about_to_become_noncommunicating
    @about_to_become_noncommunicating ||= create_business(
      cop_due_on: Date.today - 2.days,
      cop_state: Organization::COP_STATE_ACTIVE
    )
  end

  def about_to_become_delisted
    @about_to_become_delisted ||= create_business(
      cop_due_on: Date.today - 3.years,
      cop_state: Organization::COP_STATE_NONCOMMUNICATING
    )
  end

  def create_business(params = {})
    defaults = { participant: true }

    create_organization(params.reverse_merge(defaults)).tap do |o|
      o.approve!

      # this has to be done after approval
      o.update(
        cop_due_on: params[:cop_due_on],
        cop_state: params[:cop_state],
      )
    end
  end

  def mailer
    @mailer ||= mock('cop_mailer').tap do |m|
      m.responds_like_instance_of(CopMailer)
      m.stubs(delisting_today: stub(:deliver))
    end
  end

  def logger
    @logger ||= stub(:info, :error)
  end

end
