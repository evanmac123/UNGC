FactoryGirl.define do
  factory :due_diligence_review, class: DueDiligence::Review do
    association :organization, factory: :organization_with_participant_manager
    association :event, factory: :event

    requester factory: :contact

    level_of_engagement :speaker
    individual_subject { Faker::Lorem.sentence }

    additional_information { Faker::Lorem.sentence }

    trait :with_research do
      world_check_allegations { Faker::Lorem.sentence }
      additional_research { Faker::Lorem.sentence }
      analysis_comments { Faker::Lorem.sentence }

      requires_local_network_input true
      local_network_input { Faker::Lorem.sentence }

      included_in_global_marketplace true
      subject_to_sanctions true
      excluded_by_norwegian_pension_fund true
      involved_in_landmines true
      involved_in_tobacco true
      subject_to_dialog_facilitation true

      esg_score :esg_na
      highest_controversy_level :moderate_controversy
      rep_risk_peak 0
      rep_risk_current 0
      rep_risk_severity_of_news :risk_severity_bbb
    end

    trait :integrity_review do
      state :integrity_review

      integrity_explanation { Faker::Lorem.sentence }

      with_reservation :integrity_reservation
    end

    trait :engagement_review do
      state :engagement_review

      integrity_explanation { Faker::Lorem.sentence }

      with_reservation :integrity_reservation

      approving_chief { Faker::Name.first_name }
      engagement_rationale { Faker::Lorem.sentence }
    end

    trait :rejected do
      state :rejected
    end

    trait :engaged do
      state :engaged
    end

    trait :declined do
      state :declined
    end

    trait :with_declination do
      reason_for_decline :integrity
    end
  end
end
