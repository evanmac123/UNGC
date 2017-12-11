class DueDiligence::Review < ActiveRecord::Base
  belongs_to :organization
  belongs_to :requester, class_name: 'Contact'
  belongs_to :event

  validates_presence_of :requester
  validates_length_of :integrity_explanation, maximum: 1_000
  validates_length_of :engagement_rationale,
                      :world_check_allegations,
                      :local_network_input , maximum: 2_000
  validates_length_of :additional_research,
                      :analysis_comments, maximum: 65_535
  validates_length_of :approving_chief,
                      :individual_subject, maximum: 100
  validates_length_of :additional_information, maximum: 512

  enum with_reservation: {
      no_reservation: 10,
      integrity_reservation: 20,
  }
  validates :with_reservation,  inclusion: { in: self.with_reservations },
            if: -> (review) { review.state == 'engagement_review' }

  enum level_of_engagement: {
      speaker: 10,
      foundation: 15,
      sponsor: 20,
      award_recipient: 30,
      lead: 40,
      partner: 50,
      other_engagement: 100
  }
  validates :level_of_engagement,  inclusion: { in: self.level_of_engagements }

  enum rep_risk_severity_of_news: {
      severity_of_news_na: 5,
      risk_severity_aaaa: 10,
      risk_severity_aa: 20,
      risk_severity_a: 30,
      risk_severity_bbb: 40,
      risk_severity_bb: 50,
      risk_severity_b: 60,
      risk_severity_ccc: 70,
      risk_severity_cc: 80,
      risk_severity_c: 90,
      risk_severity_d: 100
  }
  validates_inclusion_of :rep_risk_severity_of_news,  in: self.rep_risk_severity_of_news, if: :integrity_review?

  enum reason_for_decline: {
      integrity: 10,
      not_available_but_interested: 20,
      ungc_priorities: 30,
      organization_financials: 40,
      other_reason: 100,
  }
  validates_inclusion_of :reason_for_decline,  in: self.reason_for_declines, if: :declined?

  enum esg_score: {
      esg_na: 10,
      industry_laggard: 20,
      underperformer: 30,
      average_performer: 40,
      outperformer: 50,
      industry_leader: 60,
  }
  validates_inclusion_of :esg_score,  in: self.esg_scores, if: :integrity_review?

  enum highest_controversy_level: {
      controversy_na: 5,
      low_controversy: 10,
      moderate_controversy: 20,
      significant_controversy: 30,
      high_controversy: 40,
      severe_controversy: 50,
  }

  validates_inclusion_of :highest_controversy_level,  in: self.highest_controversy_levels,  if: :integrity_review?


  has_many :comments, as: :commentable

  ALL_STATES = [:in_review, :local_network_review, :integrity_review, :engagement_review, :engaged, :declined, :rejected]

  state_machine initial: :new_review do
    state :in_review do # in integrity data collection
      validates_presence_of :requester_id, :organization_id, :additional_information
      validates_presence_of :individual_subject, if: :requires_individual_subject?
    end

    state :local_network_review do
      validates_presence_of :requires_local_network_input
    end

    state :integrity_review do # data is being reviewed by Integrity for a decision
      validates_presence_of :world_check_allegations,
                            :analysis_comments
      validates :included_in_global_marketplace,
                :subject_to_sanctions,
                :excluded_by_norwegian_pension_fund,
                :involved_in_landmines,
                :involved_in_tobacco,
                :subject_to_dialog_facilitation,
                :requires_local_network_input,
                inclusion: { in: [true, false] }
      validates_presence_of :local_network_input, if: :requires_local_network_input?
      validates :rep_risk_peak,
                                :rep_risk_current,
                                numericality: { only_integer: true },
                                inclusion: -1..100
    end

    state :rejected do
      validates_presence_of :integrity_explanation
    end

    state :engagement_review do
      validates_presence_of :integrity_explanation
    end

    state :engaged do
      validates_presence_of :engagement_rationale, :approving_chief, if: :integrity_reservation?
    end

    state :declined do
      validates_presence_of :engagement_rationale
    end

    event :send_to_review do
      transition [:new_review, :local_network_review, :integrity_review] => :in_review
    end

    event :request_local_network_input do
      transition [:in_review] => :local_network_review
    end

    event :request_integrity_review do
      transition [:in_review, :local_network_review, :engagement_review, :rejected] => :integrity_review
    end

    event :approve do
      transition [:integrity_review] => :engagement_review
    end

    event :approve_with_reservation do
      transition [:integrity_review] => :engagement_review
    end

    event :revert_to_engagement_decision do
      transition [:engaged, :declined] => :engagement_review
    end

    event :reject do
      transition [:integrity_review] => :rejected
    end

    event :engage do
      transition [:engagement_review] => :engaged
    end

    event :decline do
      transition [:engagement_review] => :declined
    end
  end

  def send_to_review(requester)
    if super
      DueDiligenceReviewMailer.new_review_for_research(self.id, requester).deliver_later

      publish_transition_event(requester)
    end
  end

  def request_local_network_input(requester)
    self.requires_local_network_input = true
    publish_transition_event(requester) if super
  end

  def request_integrity_review(requester)
    if super
      DueDiligenceReviewMailer.new_review_for_integrity_decision(self.id, requester).deliver_later

      publish_transition_event(requester)
    end
  end

  def approve_with_reservation(requester)
    if super
      self.with_reservation = :integrity_reservation

      DueDiligenceReviewMailer.integrity_decision_rendered(self.id, requester).deliver_later

      publish_transition_event(requester, with_reservation: :integrity_reservation)
    end
  end

  def revert_to_engagement_decision(contact)
    publish_transition_event(requester) if super
  end

  def approve(contact)
    self.with_reservation = :no_reservation
    self.reason_for_decline = nil

    if super
      DueDiligenceReviewMailer.integrity_decision_rendered(self.id, contact).deliver_later

      publish_transition_event(requester, with_reservation: self.with_reservation)
    end
  end

  def engage(contact)
    if super
      DueDiligenceReviewMailer.engagement_decision_rendered(self.id, contact).deliver_later

      self.reason_for_decline = nil
      publish_transition_event(requester,
                               with_reservation: self.with_reservation,
                               approving_chief: self.approving_chief)
    end
  end

  def decline(contact)
    if super
      DueDiligenceReviewMailer.engagement_decision_rendered(self.id, contact).deliver_later

      publish_transition_event(requester, reason_for_decline: self.reason_for_decline)
    end
  end

  def reject(contact)
    if super
      DueDiligenceReviewMailer.integrity_decision_rendered(self.id, contact).deliver_later

      publish_transition_event(requester)
    end
  end

  scope :for_state, -> (state) { where(state: state) }
  scope :related_to_contact, -> (contact, only_requested=false) {
    return all if DueDiligence::ReviewPolicy.from_integrity?(contact)

    return where(requester_id: contact.id) if only_requested

    includes(:organization)
        .joins('LEFT OUTER JOIN organizations ON organizations.id = due_diligence_reviews.organization_id')
        .where('(requester_id = :contact_id ' \
                'OR organizations.participant_manager_id = :contact_id)', contact_id: contact.id)
  }

  def requires_individual_subject?
    speaker? || foundation?
  end

  def self.review_steps
    [
      :in_review,
      :integrity_review,
      :engagement_review,
    ]
  end

  def review_step_index
    steps = self.class.review_steps
    steps.index(state) || steps.length - 1
  end

  def self.rep_risk_severity
    rep_risk_severity_of_news
  end

  def self.levels_of_engagement
    level_of_engagements
  end

  def self.esg_score_values
    esg_scores
  end

  def self.highest_controversy_level_values
    highest_controversy_levels
  end

  def self.reason_for_declines_for_reservations(reservation)
    # if there are no reservations, then we don't present an option to decline because of Integrity
    reservation ? reason_for_declines.keys : reason_for_declines.except(:integrity).keys
  end

  def organization_name
    organization&.name
  end

  def event_title
    event&.title
  end

  # allow comments on approved and rejected reviews
  def allow_comments?
    true
  end

  def publish_transition_event(requester, context_data={})
    event_store = RailsEventStore::Client.new
    stream_name = "due_diligence_review_#{id}"

    payload = {
        review_id: self.id,
        requester_id: requester.id,
    }.merge(context_data)

    event = DueDiligence::Events::ReviewRequested.new(data: payload)

    event = case self.state
      when 'in_review'
        DueDiligence::Events::ReviewRequested.new(data: payload)
      when 'local_network_review'
        DueDiligence::Events::LocalNetworkInputRequested.new(data: payload)
      when 'integrity_review'
        DueDiligence::Events::IntegrityReviewRequested.new(data: payload)
      when 'engagement_review'
        DueDiligence::Events::IntegrityApproval.new(data: payload)
      when 'rejected'
        DueDiligence::Events::IntegrityRejection.new(data: payload)
      when 'engaged'
        DueDiligence::Events::Engaged.new(data: payload)
      when 'declined'
        DueDiligence::Events::Declined.new(data: payload)
    end
    event_store.publish_event(event, stream_name: stream_name)
  end
end
