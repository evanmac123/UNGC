require 'test_helper'

class CopStatusUpdaterTest < ActiveSupport::TestCase

  setup do
    @status_updater = CopStatusUpdater.new(logger, mailer)
    @active = {
      cop_due_on: Date.today - 2.days,
      cop_state: Organization::COP_STATE_ACTIVE
    }
    @noncommunicating = {
      cop_due_on: Date.today - 3.years,
      cop_state: Organization::COP_STATE_NONCOMMUNICATING
    }
  end

  context 'active participants with COP due' do

    should 'move businesses to non-communicating status' do
      business = create_business(@active)
      assert business.active?
      @status_updater.update_all
      assert business.reload.noncommunicating?
    end

    should 'move non-businesses to non-communicating status' do
      non_business = create_non_business(@active)
      assert non_business.active?
      @status_updater.update_all
      assert non_business.reload.noncommunicating?
    end

  end

  context 'non-communicating participants with very late COP' do

    should 'delist businesses' do
      business = create_business(@noncommunicating)
      assert business.noncommunicating?
      @status_updater.update_all
      assert business.reload.delisted?
    end

    should 'delist non-businesses' do
      non_business = create_non_business(@noncommunicating)
      assert non_business.noncommunicating?
      @status_updater.update_all
      assert non_business.reload.delisted?
    end

  end

  context 'logging' do

    setup do
      @active_business = create_business(@active)
      @active_non_business = create_non_business(@active)
      @noncommunicating_business = create_business(@noncommunicating)
      @noncommunicating_non_business = create_non_business(@noncommunicating)

      @updater = CopStatusUpdater.new(logger, mailer)
    end

    should 'not have logged any errors' do
      logger.expects(:error).never
      @updater.update_all
    end

    context "non-communicating" do

      should 'log the acitve -> non-communicating phase' do
        logger.expects(:info).with("Running move_active_organizations_to_noncommunicating")
        @updater.update_all
      end

      should 'log the newly non-communicating business' do
        message = "#{@active_business.id}: #{@active_business.name} is Non-Communicating"
        logger.expects(:info).with(message)
        @updater.update_all
      end

      should 'log the newly non-communicating non-business' do
        message = "#{@active_non_business.id}: #{@active_non_business.name} is Non-Communicating"
        logger.expects(:info).with(message)
        @updater.update_all
      end

    end

    context "delisted" do

      setup {
        @business = "#{@noncommunicating_business.id}:#{@noncommunicating_business.name}"
        @non_business = "#{@noncommunicating_non_business.id}:#{@noncommunicating_non_business.name}"
      }

      should 'log the non-communicating -> delisted phase' do
        logger.expects(:info).with("Running move_noncommunicating_organizations_to_delisted")
        @updater.update_all
      end

      should 'log the newly delisted business' do
        logger.expects(:info).with("Delisted #{@business}")
        @updater.update_all
      end

      should 'log the newly delisted non-business' do
        logger.expects(:info).with("Delisted #{@non_business}")
        @updater.update_all
      end

      should 'log that the newly delisted business was emailed' do
        logger.expects(:info).with("emailed delisted #{@business}")
        @updater.update_all
      end

      should 'log that the newly delisted non-business was emailed' do
        logger.expects(:info).with("emailed delisted #{@non_business}")
        @updater.update_all
      end

    end

  end

  context 'emailing' do

    setup do
      @updater = CopStatusUpdater.new(logger)
    end

    should 'send an email to delisted businesses' do
      organization = create_business(@noncommunicating)
      CopMailer.expects(:delisting_today)
        .with(organization)
        .returns(stub(:deliver))
        .once
        @updater.update_all
    end

    should 'send an email to delisted non-businesses' do
      organization = create_business(@noncommunicating)
      CoeMailer.expects(:delisting_today)
        .with(organization)
        .returns(stub(:deliver))
        .once
        @updater.update_all
    end

  end

  private

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
