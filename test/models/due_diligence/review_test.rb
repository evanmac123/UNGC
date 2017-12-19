require 'test_helper'

class DueDiligence::ReviewTest < ActiveSupport::TestCase

  context 'validations' do
    context 'limits' do
      should 'validate length limits' do
        too_long_65535 = Faker::Lorem.characters(65_536)
        too_long_2000 = Faker::Lorem.characters(2_001)
        too_long_100 = Faker::Lorem.characters(101)

        review = FactoryGirl.build_stubbed(:due_diligence_review)

        review.world_check_allegations = too_long_2000
        review.local_network_input = too_long_2000
        review.integrity_explanation = Faker::Lorem.characters(1_001)

        review.analysis_comments = too_long_65535
        review.engagement_rationale = too_long_2000

        review.additional_research = too_long_65535

        review.individual_subject = too_long_100
        review.approving_chief = too_long_100
        review.additional_information = Faker::Lorem.characters(513)

        assert_not review.valid?, 'review is valid with max length violations'

        assert_equal review.errors[:world_check_allegations], ['is too long (maximum is 2000 characters)']
        assert_equal review.errors[:local_network_input], ['is too long (maximum is 2000 characters)']
        assert_equal review.errors[:integrity_explanation], ['is too long (maximum is 1000 characters)']

        assert_equal review.errors[:analysis_comments], ['is too long (maximum is 65535 characters)']
        assert_equal review.errors[:engagement_rationale], ['is too long (maximum is 2000 characters)']

        assert_equal review.errors[:additional_research], ['is too long (maximum is 65535 characters)']

        assert_equal review.errors[:approving_chief], ['is too long (maximum is 100 characters)']
        assert_equal review.errors[:individual_subject], ['is too long (maximum is 100 characters)']
        assert_equal review.errors[:additional_information], ['is too long (maximum is 512 characters)']
      end
    end

    context 'enums' do
      context 'level_of_engagement' do
        should 'include the correct options' do
          keys = %w[speaker
                    foundation
                    sponsor
                    award_recipient
                    lead
                    partner
                    other_engagement
                  ].sort

          assert_equal DueDiligence::Review.levels_of_engagement.keys.sort, keys
        end

        should 'accept valid values' do
          review = FactoryGirl.build_stubbed(:due_diligence_review)

          review.level_of_engagement = :sponsor
          assert review.valid?, 'level_of_engagement :sponsor was invalid'

          review.level_of_engagement = :speaker
          assert review.valid?, 'level_of_engagement :speaker was invalid'

          review.level_of_engagement = :award_recipient
          assert review.valid?, 'level_of_engagement :award_recipient was invalid'

          review.level_of_engagement = :lead
          assert review.valid?, 'level_of_engagement :lead was invalid'

          review.level_of_engagement = :partner
          assert review.valid?, 'level_of_engagement :partner was invalid'

          review.level_of_engagement = :other_engagement
          assert review.valid?, 'level_of_engagement :other_engagement was invalid'
        end

        should 'disallow an invalid value' do
          review = FactoryGirl.build(:due_diligence_review)

          exception = assert_raises( ::ArgumentError) { review.level_of_engagement = :invalid }
          assert_equal("'invalid' is not a valid level_of_engagement", exception.message)
        end
      end

      context 'reason_for_decline' do
        should 'accept valid values' do
          review = FactoryGirl.build_stubbed(:due_diligence_review)

          review.reason_for_decline = :integrity
          assert review.valid?, 'reason_for_decline :integrity was invalid'

          review.reason_for_decline = :not_available_but_interested
          assert review.valid?, 'reason_for_decline :not_available_but_interested was invalid'

          review.reason_for_decline = :ungc_priorities
          assert review.valid?, 'reason_for_decline :ungc_priorities was invalid'

          review.reason_for_decline = :organization_financials
          assert review.valid?, 'reason_for_decline :organization_financials was invalid'

          review.reason_for_decline = :other_reason
          assert review.valid?, 'reason_for_decline :other_reason was invalid'
        end

        should 'disallow an invalid value' do
          review = FactoryGirl.build(:due_diligence_review)

          exception = assert_raises( ::ArgumentError) { review.reason_for_decline = :invalid }
          assert_equal("'invalid' is not a valid reason_for_decline", exception.message)
        end
      end

      context 'rep_risk_severity_of_news' do
        should 'accept valid values' do
          review = FactoryGirl.build_stubbed(:due_diligence_review)

          review.rep_risk_severity_of_news = :severity_of_news_na
          assert review.valid?, 'rep_risk_severity_of_news :severity_of_news_na was invalid'

          review.rep_risk_severity_of_news = :risk_severity_aaaa
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_aaa was invalid'

          review.rep_risk_severity_of_news = :risk_severity_aa
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_aa was invalid'

          review.rep_risk_severity_of_news = :risk_severity_a
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_a was invalid'

          review.rep_risk_severity_of_news = :risk_severity_bbb
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_bbb was invalid'

          review.rep_risk_severity_of_news = :risk_severity_bb
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_bb was invalid'

          review.rep_risk_severity_of_news = :risk_severity_b
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_b was invalid'

          review.rep_risk_severity_of_news = :risk_severity_ccc
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_ccc was invalid'

          review.rep_risk_severity_of_news = :risk_severity_cc
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_cc was invalid'

          review.rep_risk_severity_of_news = :risk_severity_c
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_c was invalid'

          review.rep_risk_severity_of_news = :risk_severity_d
          assert review.valid?, 'rep_risk_severity_of_news :risk_severity_d was invalid'
        end

        should 'disallow an invalid value' do
          review = FactoryGirl.build(:due_diligence_review)

          exception = assert_raises( ::ArgumentError) { review.rep_risk_severity_of_news = :invalid }
          assert_equal("'invalid' is not a valid rep_risk_severity_of_news", exception.message)
        end
      end

      context 'with_reservation' do
        should 'accept valid values' do
          review = FactoryGirl.build_stubbed(:due_diligence_review)

          review.with_reservation = :no_reservation
          assert review.valid?, 'with_reservation :no_reservation was invalid'

          review.rep_risk_severity_of_news = :risk_severity_aa
          assert review.valid?, 'with_reservation :integrity_reservation was invalid'
        end

        should 'disallow an invalid value' do
          review = FactoryGirl.build(:due_diligence_review)

          exception = assert_raises( ::ArgumentError) { review.with_reservation = :invalid }
          assert_equal("'invalid' is not a valid with_reservation", exception.message)
        end
      end

      context 'highest_controversy_level' do
        should 'accept valid values' do
          review = FactoryGirl.build_stubbed(:due_diligence_review, :with_research, :integrity_review)

          review.highest_controversy_level = :controversy_na
          assert review.valid?, 'highest_controversy_level :controversy_na was invalid'

          review.highest_controversy_level = :low_controversy
          assert review.valid?, 'highest_controversy_level :low_controversy was invalid'

          review.highest_controversy_level = :moderate_controversy
          assert review.valid?, 'highest_controversy_level :moderate_controversy was invalid'

          review.highest_controversy_level = :significant_controversy
          assert review.valid?, 'highest_controversy_level :significant_controversy was invalid'

          review.highest_controversy_level = :high_controversy
          assert review.valid?, 'highest_controversy_level :high_controversy was invalid'

          review.highest_controversy_level = :severe_controversy
          assert review.valid?, 'highest_controversy_level :severe_controversy was invalid'
        end

        should 'disallow an invalid value' do
          review = FactoryGirl.build(:due_diligence_review, :with_research, :integrity_review)

          exception = assert_raises( ::ArgumentError) { review.highest_controversy_level = :invalid }
          assert_equal("'invalid' is not a valid highest_controversy_level", exception.message)
        end
      end

      context 'rep_risk_scores' do
        should 'accept valid values' do
          review = FactoryGirl.build_stubbed(:due_diligence_review, :with_research, :integrity_review)

          review.rep_risk_peak = -1
          assert review.valid?, 'rep_risk_peak -1 was invalid'

          review.rep_risk_peak = 0
          assert review.valid?, 'rep_risk_peak 0 was invalid'

          review.rep_risk_peak = 100
          assert review.valid?, 'rep_risk_peak 100 was invalid'

          review.rep_risk_current = -1
          assert review.valid?, 'rep_risk_current -1 was invalid'

          review.rep_risk_current = 0
          assert review.valid?, 'rep_risk_current 0 was invalid'

          review.rep_risk_current = 100
          assert review.valid?, 'rep_risk_current 100 was invalid'
        end

        should 'disallow an invalid value' do
          review = FactoryGirl.build(:due_diligence_review, :with_research, :integrity_review)

          exception = assert_raises( ::ArgumentError) { review.highest_controversy_level = :invalid }
          assert_equal("'invalid' is not a valid highest_controversy_level", exception.message)
        end
      end
    end
  end

  test "path to integrity_review approval" do
    review = FactoryGirl.create(:due_diligence_review)

    assert review.send_to_review(review.requester), review.reload.errors.full_messages

    review.world_check_allegations = 'text'
    review.local_network_input = 'text'
    review.analysis_comments = 'text'

    review.requires_local_network_input = true
    review.included_in_global_marketplace = true
    review.subject_to_sanctions = true
    review.excluded_by_norwegian_pension_fund = true
    review.involved_in_landmines = true
    review.involved_in_tobacco = true
    review.subject_to_dialog_facilitation = true


    review.esg_score = :esg_na
    review.highest_controversy_level = :moderate_controversy
    review.rep_risk_peak = 0
    review.rep_risk_current = 0
    review.rep_risk_severity_of_news = :risk_severity_aa

    review.with_reservation = :no_reservation

    integrity_user = FactoryGirl.create(:staff_contact, :integrity_team_member)
    assert review.request_integrity_review(integrity_user), review.reload.errors.full_messages

    review.additional_research = 'Yes'
    review.integrity_explanation = 'Imperious smirk.'

    integrity_manager = FactoryGirl.create(:staff_contact, :integrity_manager)
    assert review.approve(integrity_manager), review.reload.errors.full_messages

    review.engagement_rationale = 'I think we should go ahead.'
    review.approving_chief = 'Chuck E. Cheese'

    assert review.engage(review.requester), review.reload.errors.full_messages
  end

  context 'state transitions' do
    context 'in_review' do
      should "succeed from new_request" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review)

        assert review.send_to_review(contact), review.reload.errors.full_messages
        assert review.in_review?, 'state not in_review'
      end

      should "succeed from integrity_review" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research, state: :integrity_review)

        assert review.send_to_review(contact), review.reload.errors.full_messages
        assert review.in_review?, 'state not in_review'
      end

      should "require :requester, :organization, :level_of_engagement and :additional_information" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research)

        review.requester_id = ''
        review.organization_id = ''
        review.level_of_engagement = ''
        review.additional_information = ''

        assert_not review.send_to_review(contact), review.reload.errors.full_messages
        assert review.integrity_review?, 'state not integrity_review'

        assert_includes review.reload.errors.full_messages, "Requester can't be blank"
        assert_includes review.reload.errors.full_messages, "Organization can't be blank"
        assert_includes review.reload.errors.full_messages, "Level of engagement is not included in the list"
        assert_includes review.reload.errors.full_messages, "Additional information can't be blank"
      end

      should "require :individual_subject for a :speaker and :foundation" do
        [:speaker, :foundation].each do |review_type|
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review)

          review.level_of_engagement = review_type
          review.individual_subject = ''

          assert_not review.send_to_review(contact),
                     review.reload.errors.full_messages.to_s
          assert review.new_review?, "state not new_review (type=#{review_type} state: #{review.state}"

          assert_includes review.reload.errors.full_messages,
                          "Individual subject can't be blank", "for review_type=#{review_type}"
        end
      end

      should "fire a review_requested event" do
        contact = create(:staff_contact)
        organization = create(:organization)
        level_of_engagement = :sponsor
        additional_information = 'To be all that I can be.'

        review = FactoryGirl.create(:due_diligence_review, :with_research,
                                    requester: contact,
                                    organization: organization,
                                    level_of_engagement: level_of_engagement,
                                    additional_information: additional_information,
        )

        review.send_to_review(contact)

        # it should not set validation errors
        assert_empty review.errors.full_messages

        # it should publish an event
        event = first_event("due_diligence_review_#{review.id}",
                            DueDiligence::Events::ReviewRequested)

        assert_equal contact.id, event.data.fetch(:requester_id)
        assert_equal review.id, event.data.fetch(:review_id)
      end

      should "use the overridden methods" do
        review = FactoryGirl.create(:due_diligence_review)

        assert_raises( ::ArgumentError) { review.send_to_review }
        assert_raises(::ArgumentError) { review.send_to_review! }
      end
    end

    context 'request_local_network_input' do
      should "succeed" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review, state: :in_review)

        assert review.request_local_network_input(contact), review.reload.errors.full_messages
        assert review.local_network_review?, 'state not local_network_review'
      end

      should "set local_network_input_required" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review,
                                    state: :in_review,
                                    requires_local_network_input: nil,
        )

        assert review.request_local_network_input(contact), review.reload.errors.full_messages

        review.reload

        assert review.requires_local_network_input?, 'requires_local_network_input should be set'
        assert review.local_network_review?, 'state not local_network_review?'
      end

      should "fire a additional_local_network_input_requested event" do
        contact = create(:staff_contact)
        organization = create(:organization)
        level_of_engagement = :award_recipient
        additional_information = 'To be all that I can be.'

        review = FactoryGirl.create(:due_diligence_review, :with_research,
                                    state: :in_review,
                                    requester: contact,
                                    organization: organization,
                                    level_of_engagement: level_of_engagement,
                                    additional_information: additional_information,
        )

        review.request_local_network_input(contact)

        # it should not set validation errors
        assert_empty review.errors.full_messages

        # it should publish an event
        event = first_event("due_diligence_review_#{review.id}",
                            DueDiligence::Events::LocalNetworkInputRequested)

        assert_equal contact.id, event.data.fetch(:requester_id)
        assert_equal review.id, event.data.fetch(:review_id)
      end

      should "use the overridden methods" do
        review = FactoryGirl.create(:due_diligence_review)

        assert_raises( ::ArgumentError) { review.request_local_network_input }
        assert_raises(::ArgumentError) { review.request_local_network_input! }
      end
    end

    context 'request_integrity_review' do
      should "succeed" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review, :with_research, state: :in_review)

        assert review.request_integrity_review(contact), review.reload.errors.full_messages
        assert review.integrity_review?, 'state not integrity_review'
      end

      should "succeed from local_network_review" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review, :with_research, state: :local_network_review)

        assert review.request_integrity_review(contact), review.reload.errors.full_messages
        assert review.integrity_review?, 'state not integrity_review'
      end

      should "require necessary research attributes" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review,
                                    state: :in_review,
                                    local_network_input: '',
                                    requires_local_network_input: false,
        )

        assert_not review.request_integrity_review(contact), review.reload.errors.full_messages
        assert review.in_review?, 'state not in_review'
        review.reload

        assert_includes review.errors.full_messages, "World check allegations can't be blank"
        assert_includes review.errors.full_messages, "Included in global marketplace is not included in the list"
        assert_includes review.errors.full_messages, "Subject to sanctions is not included in the list"
        assert_includes review.errors.full_messages, "Excluded by norwegian pension fund is not included in the list"
        assert_includes review.errors.full_messages, "Involved in landmines is not included in the list"
        assert_includes review.errors.full_messages, "Involved in tobacco is not included in the list"
        assert_includes review.errors.full_messages, "Esg score is not included in the list"
        assert_includes review.errors.full_messages, "Subject to dialog facilitation is not included in the list"
        assert_includes review.errors.full_messages, "Highest controversy level is not included in the list"
        assert_includes review.errors.full_messages, "Rep risk peak is not a number"
        assert_includes review.errors.full_messages, "Rep risk peak is not included in the list"
        assert_includes review.errors.full_messages, "Rep risk current is not a number"
        assert_includes review.errors.full_messages, "Rep risk current is not included in the list"
        assert_includes review.errors.full_messages, "Rep risk severity of news is not included in the list"
        assert_includes review.errors.full_messages, "Analysis comments can't be blank"
      end

      should "validate rep risk current and peak values" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.build_stubbed(:due_diligence_review,
                                    :integrity_review,
                                    rep_risk_current: 9.9,
                                    rep_risk_peak: 2.3,
        )

        assert_not review.valid?

        assert_includes review.errors.full_messages, "Rep risk peak must be an integer"
        assert_includes review.errors.full_messages, "Rep risk current must be an integer"

        review = FactoryGirl.build_stubbed(:due_diligence_review,
                                           :integrity_review,
                                           rep_risk_current: -2,
                                           rep_risk_peak: -101,
        )

        assert_not review.valid?

        assert_includes review.errors.full_messages, "Rep risk current is not included in the list"
        assert_includes review.errors.full_messages, "Rep risk peak is not included in the list"

        review = FactoryGirl.build_stubbed(:due_diligence_review,
                                           :integrity_review,
                                           rep_risk_current: 120,
                                           rep_risk_peak: 999,
        )

        assert_not review.valid?

        assert_includes review.errors.full_messages, "Rep risk current is not included in the list"
        assert_includes review.errors.full_messages, "Rep risk peak is not included in the list"
      end

      should "require local_network_input if so flagged" do
        contact = FactoryGirl.create(:contact)
        review = FactoryGirl.create(:due_diligence_review, state: :in_review,
                                    local_network_input: '',
                                    requires_local_network_input: true
        )

        assert_not review.request_integrity_review(contact), review.reload.errors.full_messages
        assert review.in_review?, 'state not in_review'
        review.reload

        assert_includes review.errors.full_messages, "Local network input can't be blank"
      end

      should "fire an integrity review_requested event" do
        contact = create(:staff_contact)
        organization = create(:organization)
        level_of_engagement = :award_recipient
        additional_information = 'To be all that I can be.'

        review = FactoryGirl.create(:due_diligence_review, :with_research,
                                    state: :in_review,
                                    requester: contact,
                                    organization: organization,
                                    level_of_engagement: level_of_engagement,
                                    additional_information: additional_information,
        )

        review.request_integrity_review(contact)

        # it should not set validation errors
        assert_empty review.errors.full_messages

        # it should publish an event
        event = first_event("due_diligence_review_#{review.id}",
                            DueDiligence::Events::IntegrityReviewRequested)

        assert_equal contact.id, event.data.fetch(:requester_id)
        assert_equal review.id, event.data.fetch(:review_id)
      end

      should "use the overridden methods" do
        review = FactoryGirl.create(:due_diligence_review)

        assert_raises( ::ArgumentError) { review.request_integrity_review }
        assert_raises(::ArgumentError) { review.request_integrity_review! }
      end
    end

    context 'integrity_review decisions' do
      context 'on approve' do
        should "succeed" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research, with_reservation: nil)

          assert review.approve(contact), review.reload.errors.full_messages
          assert review.engagement_review?, 'state not engagement_review'
        end

        should "require an explanation" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      integrity_explanation: '')

          assert_not review.approve(contact), review.reload.errors.full_messages
          assert review.integrity_review?, 'state not integrity_review'
          assert_includes review.reload.errors.full_messages, "Integrity explanation can't be blank"
        end

        should "fire an integrity approval event" do
          contact = create(:staff_contact)
          organization = create(:organization)
          level_of_engagement = :partner
          additional_information = 'To be all that I can be.'
          additional_research = 'I recommend.'
          integrity_explanation = 'Let me explain...'
          with_reservation = :integrity_reservation # The event should set this to :no_reservation

          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      requester: contact,
                                      organization: organization,
                                      level_of_engagement: level_of_engagement,
                                      additional_information: additional_information,
                                      additional_research: additional_research,
                                      integrity_explanation: integrity_explanation,
          )

          review.approve(contact)

          # it should not set validation errors
          assert_empty review.errors.full_messages

          # it should publish an event
          event = first_event("due_diligence_review_#{review.id}",
                              DueDiligence::Events::IntegrityApproval)

          assert_equal contact.id, event.data.fetch(:requester_id)
          assert_equal review.id, event.data.fetch(:review_id)
          assert_equal 'no_reservation', event.data.fetch(:with_reservation)
        end

        should "use the overridden methods" do
          review = FactoryGirl.create(:due_diligence_review)

          assert_raises( ::ArgumentError) { review.approve }
          assert_raises(::ArgumentError) { review.approve! }
        end
      end

      context 'on approve_with_reservation' do
        should "succeed" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research)

          assert review.approve_with_reservation(contact), review.reload.errors.full_messages
          assert review.engagement_review?, 'state not engagement_review'
        end

        should "require an explanation" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      integrity_explanation: '')

          assert_not review.approve_with_reservation(contact), review.reload.errors.full_messages
          assert review.integrity_review?, 'state not integrity_review'
          assert_includes review.reload.errors.full_messages, "Integrity explanation can't be blank"
        end

        should "fire an integrity approval event" do
          contact = create(:staff_contact)
          organization = create(:organization)
          level_of_engagement = :partner
          additional_information = 'To be all that I can be.'
          additional_research = 'I recommend.'
          integrity_explanation = 'Let me explain...'
          with_reservation = :no_reservation # The event should set this to :integrity_reservation

          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      requester: contact,
                                      organization: organization,
                                      level_of_engagement: level_of_engagement,
                                      additional_information: additional_information,
                                      additional_research: additional_research,
                                      integrity_explanation: integrity_explanation,
                                      with_reservation: with_reservation
          )

          review.approve_with_reservation(contact)

          # it should not set validation errors
          assert_empty review.errors.full_messages

          # it should publish an event
          event = first_event("due_diligence_review_#{review.id}",
                              DueDiligence::Events::IntegrityApproval)
          assert_equal contact.id, event.data.fetch(:requester_id)
          assert_equal review.id, event.data.fetch(:review_id)
          assert_equal :integrity_reservation, event.data.fetch(:with_reservation)
        end

        should "use the overridden methods" do
          review = FactoryGirl.create(:due_diligence_review)

          assert_raises( ::ArgumentError) { review.approve_with_reservation }
          assert_raises(::ArgumentError) { review.approve_with_reservation! }
        end
      end

      context 'on reject' do
        should "not require a final decision or approving_chief" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research, )
          assert review.reject(contact), review.reload.errors.full_messages
          assert review.rejected?, 'state not rejected'
        end

        should "require an explanation" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      integrity_explanation: '')

          assert_not review.approve(contact), review.reload.errors.full_messages
          assert review.integrity_review?, 'state not integrity_review'
          assert_includes review.reload.errors.full_messages, "Integrity explanation can't be blank"
        end

        should "fire an integrity rejection event" do
          contact = create(:staff_contact)
          organization = create(:organization)
          level_of_engagement = :other_engagement
          additional_information = 'To be all that I can be.'
          integrity_explanation = 'Let me explain...'

          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      requester: contact,
                                      organization: organization,
                                      level_of_engagement: level_of_engagement,
                                      additional_information: additional_information,
                                      integrity_explanation: integrity_explanation,
          )

          review.reject(contact)

          # it should not set validation errors
          assert_empty review.errors.full_messages

          # it should publish an event
          event = first_event("due_diligence_review_#{review.id}",
                              DueDiligence::Events::IntegrityRejection)

          assert_equal contact.id, event.data.fetch(:requester_id)
          assert_equal review.id, event.data.fetch(:review_id)
        end

        should "not fire rejected event when it's already rejected" do
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, :rejected)
          contact = create(:staff_contact)

          review.reject(contact)

          assert_empty event_store.read_all_streams_forward
        end

        should "use the overridden methods" do
          review = FactoryGirl.create(:due_diligence_review)

          assert_raises( ::ArgumentError) { review.reject }
          assert_raises(::ArgumentError) { review.reject! }
        end
      end

      context 'on return for review' do

        should "succeed" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research)

          assert review.send_to_review(contact), review.reload.errors.full_messages
          assert review.in_review?, 'state not in_review'
          assert_empty review.reload.errors
        end

        should "fire an integrity rejection event" do
          contact = create(:staff_contact)
          organization = create(:organization)
          level_of_engagement = :lead
          additional_information = 'To be all that I can be.'
          integrity_explanation = 'Let me explain...'

          review = FactoryGirl.create(:due_diligence_review, :integrity_review, :with_research,
                                      requester: contact,
                                      organization: organization,
                                      level_of_engagement: level_of_engagement,
                                      additional_information: additional_information,
                                      integrity_explanation: integrity_explanation,
          )

          review.reject(contact)

          # it should not set validation errors
          assert_empty review.errors.full_messages

          # it should publish an event
          event = first_event("due_diligence_review_#{review.id}",
                              DueDiligence::Events::IntegrityRejection)

          assert_equal contact.id, event.data.fetch(:requester_id)
          assert_equal review.id, event.data.fetch(:review_id)
        end

        should "not fire rejected event when it's already rejected" do
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, :rejected)
          contact = create(:staff_contact)

          review.reject(contact)

          assert_empty event_store.read_all_streams_forward
        end

        should "use the overridden methods" do
          review = FactoryGirl.create(:due_diligence_review)

          assert_raises( ::ArgumentError) { review.reject }
          assert_raises(::ArgumentError) { review.reject! }
        end
      end
    end

    context 'engagement_review decisions' do
      context 'on engage' do
        should "succeed" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review)
          assert review.engage(contact), review.reload.errors.full_messages
          assert review.engaged?, 'state not engaged'
        end

        should "return to integrity_review" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, :with_research)
          assert review.request_integrity_review(contact), review.reload.errors.full_messages
          assert review.integrity_review?, 'state not integrity_review'
        end

        should "not require engagement_rationale and approving_chief without integrity reservation" do
          review = FactoryGirl.create(:due_diligence_review, :engagement_review,
                                      engagement_rationale: '',
                                      approving_chief: '',
                                      with_reservation: :no_reservation)

          review.engage(review.requester)
          assert_empty review.reload.errors.full_messages, "Errors were signalled but not expected"
        end

        should "require engagement_rationale and approving_chief with an integrity reservation" do
          contact = FactoryGirl.build_stubbed(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review,
                                      engagement_rationale: '',
                                      approving_chief: '',
                                      with_reservation: :integrity_reservation)

          assert_not review.engage(contact)
          assert_includes review.reload.errors.full_messages, "Engagement rationale can't be blank"
          assert_includes review.reload.errors.full_messages, "Approving chief can't be blank"
        end

        should 'be disallowed for rejected reviews' do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review)
          review.engage(contact)
          assert_not review.engage(contact), review.reload.errors.full_messages
          assert_includes review.reload.errors.full_messages, 'State cannot transition via "engage"'
        end

        should "fire an engagement event" do
          contact = create(:staff_contact)
          engagement_rationale = 'Yes, please.'
          approving_chief = 'Chuck E. Cheese'
          with_reservation = :integrity_reservation

          review = FactoryGirl.create(:due_diligence_review, :engagement_review,
                                      requester: contact,
                                      engagement_rationale: engagement_rationale,
                                      approving_chief: approving_chief,
                                      with_reservation: with_reservation
          )

          review.engage(contact)

          # it should not set validation errors
          assert_empty review.errors.full_messages

          # it should publish an event
          event = first_event("due_diligence_review_#{review.id}",
                              DueDiligence::Events::Engaged)

          assert_equal contact.id, event.data.fetch(:requester_id)
          assert_equal review.id, event.data.fetch(:review_id)
          assert_equal approving_chief, event.data.fetch(:approving_chief)
          assert_equal with_reservation.to_s, event.data.fetch(:with_reservation)
        end

        should "use the overridden methods" do
          review = FactoryGirl.create(:due_diligence_review)

          assert_raises( ::ArgumentError) { review.engage }
          assert_raises(::ArgumentError) { review.engage! }
        end
      end

      context 'on decline' do
        should "succeed" do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, :with_declination)
          assert review.decline(contact), review.reload.errors.full_messages
          assert review.declined?, 'state not declined'
        end

        should "require engagement_rationale and approving_chief" do
          contact = FactoryGirl.build_stubbed(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review,
                                      engagement_rationale: '',
                                      approving_chief: '')
          assert_not review.decline(contact)
          assert_includes review.reload.errors.full_messages, "Engagement rationale can't be blank"
        end

        should 'require a reason for declining' do
          contact = FactoryGirl.build_stubbed(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, reason_for_decline: '')
          assert_not review.decline(contact)
          assert_includes review.reload.errors.full_messages, "Reason for decline is not included in the list"
        end

        should "fire an engagement declined event" do
          contact = create(:staff_contact)
          engagement_rationale = 'No, thank you.'
          approving_chief = 'Chuck E. Cheese'
          reason_for_decline = :not_available_but_interested

          review = FactoryGirl.create(:due_diligence_review, :engagement_review,
                                      requester: contact,
                                      engagement_rationale: engagement_rationale,
                                      approving_chief: approving_chief,
                                      reason_for_decline: reason_for_decline,
          )

          review.decline(contact)

          # it should not set validation errors
          assert_empty review.errors.full_messages

          # it should publish an event
          event = first_event("due_diligence_review_#{review.id}",
                              DueDiligence::Events::Declined)

          assert_equal contact.id, event.data.fetch(:requester_id)
          assert_equal review.id, event.data.fetch(:review_id)
          assert_equal review.reason_for_decline, event.data.fetch(:reason_for_decline)
        end

        should "use the overridden methods" do
          review = FactoryGirl.create(:due_diligence_review)

          assert_raises( ::ArgumentError) { review.decline }
          assert_raises(::ArgumentError) { review.decline! }
        end
      end
    end

    context 'decision corrections' do
      context 'rejected' do
        should 'be able to transition back to integrity_review' do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :with_research, :engagement_review, :rejected)
          assert review.request_integrity_review(contact), review.reload.errors.full_messages
          assert review.integrity_review?, 'state not integrity_review'
        end
      end

      context 'engaged' do
        should 'be able to transition back to engagement_review' do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, :engaged)
          assert review.revert_to_engagement_decision(contact), review.reload.errors.full_messages
          assert review.engagement_review?, 'state not engagement_review'
        end
      end

      context 'declined' do
        should 'be able to transition back to engagement_review' do
          contact = FactoryGirl.create(:contact)
          review = FactoryGirl.create(:due_diligence_review, :engagement_review, :declined, :with_declination)
          assert review.revert_to_engagement_decision(contact), review.reload.errors.full_messages
          assert review.engagement_review?, 'state not engagement_review'
        end
      end

      should "use the overridden methods" do
        review = FactoryGirl.create(:due_diligence_review)

        assert_raises( ::ArgumentError) { review.revert_to_engagement_decision }
        assert_raises(::ArgumentError) { review.revert_to_engagement_decision! }
      end

    end
  end


  context 'comments' do
    should 'be allowed in rejected state' do
      contact = FactoryGirl.create(:contact)
      review = FactoryGirl.create(:due_diligence_review, :engagement_review, :rejected)
      comment = review.comments.create(body: "hello world", contact_id: contact.id)
      assert_not comment.errors.any?
    end

    should 'be allowed in engagement_review' do
      contact = FactoryGirl.create(:contact)
      review = FactoryGirl.create(:due_diligence_review, :engagement_review)
      comment = review.comments.create(body: "hello world", contact_id: contact.id)
      assert_not comment.errors.any?
    end

    should 'be allowed when engaged' do
      contact = FactoryGirl.create(:contact)
      review = FactoryGirl.create(:due_diligence_review, :engagement_review, :engaged, )
      comment = review.comments.create(body: "hello world", contact_id: contact.id)
      assert_not comment.errors.any?
    end
  end

  private

  def first_event(stream_name, type)
    events = event_store.read_events_forward(stream_name)
    approved_events = events.select { |e| e.is_a? type }
    assert_equal 1, approved_events.length
    approved_events.first
  end

  def event_store
    RailsEventStore::Client.new
  end
end
