require 'minitest/autorun'

class ActionPlatformSubscriptionTest < ActiveSupport::TestCase
  describe 'validations for states' do
    let(:starts_on) { nil }
    let(:expires_on) { nil }
    let(:subscription) { FactoryGirl.build(:action_platform_subscription,
                                            state: state,
                                            starts_on: starts_on,
                                            expires_on: expires_on) }

    describe 'pending' do
      let(:state) { :pending }

      it 'do not require start/end date' do
        subscription.must_be :valid?
      end

      describe 'start/end date range' do
        let(:starts_on) { Date.current }
        let(:expires_on) { 1.day.ago }

        it 'are not applied' do
          subscription.must_be :valid?
        end
      end
    end

    describe 'approved' do
      let(:state) { :approved }

      it 'require start/end date' do
        subscription.wont_be :valid?
      end

      describe 'start/end date range' do
        let(:starts_on) { Date.current }
        let(:expires_on) { 1.day.ago }

        it 'are applied' do
          subscription.wont_be :valid?
        end

        it 'responds with validation message' do
          subscription.valid?
          subscription.errors[:expires_on].must_equal ['must be after subscription start date']
        end
      end

      describe 'overlapping start/end date range for the same platform' do
        let(:starts_on) { Date.current }
        let(:expires_on) { 1.year.from_now }

        let(:approved_subscription) {
          FactoryGirl.create(:action_platform_subscription,
                                               :approved,
                                               starts_on: starts_on,
                                               expires_on: expires_on) }
        let(:overlapping) {
          FactoryGirl.build(:action_platform_subscription,
                                               organization: approved_subscription.organization,
                                               platform: approved_subscription.platform,
                                               state: state,
                                               starts_on: starts_on,
                                               expires_on: expires_on) }

        it 'second is not valid' do
          overlapping.wont_be :valid?
        end

        it 'responds with validation message' do
          overlapping.valid?
          overlapping.errors[:base].must_equal ['Only one approved subscription can be active at once']
        end
      end
    end

    describe 'declined' do
      let(:state) { :declined }

      it 'require start/end date' do
        subscription.must_be :valid?
      end
    end
  end

  test "path to approval" do
    manager = create(:staff_contact, :action_platform_manager)
    subscription = FactoryGirl.create(:action_platform_subscription)

    assert subscription.approve!(manager), subscription.reload.errors.full_messages
  end

  describe 'state transitions' do
    let(:state) { :ce_engagement_review }
    let(:contact) { FactoryGirl.create(:contact) }
    let(:subscription) { FactoryGirl.create(:action_platform_subscription, state: state) }

    describe 'to pending' do
      describe 'from ce_engagement_review' do
        let(:state) { :ce_engagement_review }

        it "transitions to pending" do
          assert subscription.back_to_pending!(contact), subscription.reload.errors.full_messages
          assert subscription.pending?, 'state not pending?'
        end
      end

      describe 'from declined' do
        let(:state) { :declined }

        it "transitions to pending" do
          assert subscription.back_to_pending!(contact), subscription.reload.errors.full_messages
          assert subscription.pending?, 'state not pending?'
        end
      end

      describe 'from approved' do
        let(:state) { :approved }

        it "transitions to pending" do
          assert subscription.back_to_pending!(contact), subscription.reload.errors.full_messages
          assert subscription.pending?, 'state not pending?'
        end
      end

      it "use the overridden methods" do
        assert_raises( ::ArgumentError) { subscription.back_to_pending! }
        assert_raises(::ArgumentError) { subscription.back_to_pending! }
      end
    end

    describe 'to ce_engagement_review' do
      let(:state) { :pending }

      it "transitions to ce_engagement_review" do
        assert subscription.send_to_ce_review!(contact), subscription.reload.errors.full_messages
        assert subscription.ce_engagement_review?, 'state not ce_engagement_review'
      end

      describe 'invalid transitions' do
        describe 'from approved' do
          let(:state) { :approved }

          it "does not transition to ce_engagement_review" do
            assert_raises(StateMachine::InvalidTransition) { subscription.send_to_ce_review!(contact) }
          end
        end

        describe 'from declined' do
          let(:state) { :declined }

          it "does not transition to ce_engagement_review" do
            assert_raises(StateMachine::InvalidTransition) { subscription.send_to_ce_review!(contact) }
          end
        end
      end

      it "use the overridden methods" do
        assert_raises( ::ArgumentError) { subscription.send_to_ce_review! }
        assert_raises(::ArgumentError) { subscription.send_to_ce_review! }
      end
    end

    describe 'to approved' do
      let(:state) { :pending }

      describe 'from pending' do
        it "transitions to approved" do
          assert subscription.approve!(contact), subscription.reload.errors.full_messages
          assert subscription.approved?, 'state not approved'
        end
      end

      describe 'from ce_engagement_review' do
        let(:state) { :ce_engagement_review }

        it "transitions to approved" do
          assert subscription.approve!(contact), subscription.reload.errors.full_messages
          assert subscription.approved?, 'state not approved'
        end
      end

      describe 'invalid transitions' do
        describe 'from declined' do
          let(:state) { :declined }

          it "does not transition to ce_engagement_review" do
            assert_raises(StateMachine::InvalidTransition) { subscription.approve!(contact) }
          end
        end
      end

      describe 'on invalid data' do
        let(:subscription) { FactoryGirl.create(:action_platform_subscription, state: state, starts_on: nil) }

        it 'fails when dates are not valid' do
          assert_raises(StateMachine::InvalidTransition) { subscription.approve!(contact) }
          assert subscription.pending?, 'state not pending'
        end
      end

      should "use the overridden methods" do
        assert_raises( ::ArgumentError) { subscription.approve! }
        assert_raises(::ArgumentError) { subscription.approve! }
      end
    end

    describe 'to declined' do
      let(:state) { :pending }

      it "transitions to declined" do
        assert subscription.decline!(contact), subscription.reload.errors.full_messages
        assert subscription.declined?, 'state not declined'
      end

      describe 'invalid transitions' do
        describe 'from approved' do
          let(:state) { :approved }

          it "does not transition to ce_engagement_review" do
            assert_raises(StateMachine::InvalidTransition) { subscription.decline!(contact) }
          end
        end
      end

      it "use the overridden methods" do
        assert_raises( ::ArgumentError) { subscription.decline! }
        assert_raises(::ArgumentError) { subscription.decline! }
      end
    end
  end

  describe 'contact organization and subscription organization must match' do
    let(:contact) { FactoryGirl.create(:contact_point) }
    let(:subscription) { FactoryGirl.build_stubbed(:action_platform_subscription, contact: contact) }

    it 'is not valid' do
      subscription.wont_be :valid?, 'Subscription was valid'
    end

    it 'shows the correct validation message' do
      subscription.valid?
      subscription.errors[:base].must_equal ["Contact's organization is not the same as the Subscription's organization"],
                                            "Messages #{subscription.errors.full_messages}"
    end
  end
end
