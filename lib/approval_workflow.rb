module ApprovalWorkflow
  STATE_PENDING_REVIEW = 'pending_review'
  STATE_IN_REVIEW = 'in_review'
  STATE_NETWORK_REVIEW = 'network_review'
  STATE_DELAY_REVIEW = 'delay_review'
  STATE_APPROVED = 'approved'
  STATE_REJECTED = 'rejected'

  NON_REJECTED_STATES = [STATE_PENDING_REVIEW, STATE_IN_REVIEW, STATE_NETWORK_REVIEW, STATE_DELAY_REVIEW, STATE_APPROVED]

  EVENT_REVISE = 'revise'
  EVENT_RESUME_REVIEW = 'resume_review'
  EVENT_NETWORK_REVIEW = 'network_review'
  EVENT_DELAY_REVIEW = 'delay_review'
  EVENT_APPROVE = 'approve'
  EVENT_REJECT = 'reject'
  EVENT_REJECT_MICRO = 'reject_micro'

  STAFF_EVENTS = [EVENT_APPROVE, EVENT_REJECT, EVENT_REJECT_MICRO, EVENT_NETWORK_REVIEW, EVENT_DELAY_REVIEW, EVENT_RESUME_REVIEW]

  def self.included(klass)
    klass.class_eval do
      belongs_to :reviewer, :class_name => 'Contact'

      state_machine :state, :initial => :pending_review do
        event :save_as_draft do
          transition :from => :initial, :to => :draft
        end
        event :submit do
          transition :from => [:initial, :draft], :to => :pending_review
        end
        event :revise do
          transition :from => :pending_review, :to => :in_review
        end
        event :resume_review do
          transition :from => :delay_review, :to => :in_review
        end
        event :network_review do
          transition :from => [:in_review, :pending_review, :delay_review], :to => :network_review
        end
        event :delay_review do
          transition :from => [:in_review, :pending_review, :network_review], :to => :delay_review
        end
        event :approve do
          transition :from => [:in_review, :pending_review, :network_review, :delay_review], :to => :approved
        end
        event :reject do
          transition :from => [:in_review, :pending_review, :network_review, :delay_review], :to => :rejected
        end
        event :reject_micro do
          transition :from => [:in_review, :pending_review, :network_review, :delay_review], :to => :rejected
        end
      end

      scope :pending_review, -> { where(:state => STATE_PENDING_REVIEW) }
      scope :in_review, -> { where(:state => STATE_IN_REVIEW, :replied_to => true) }
      scope :network_review, -> { where(:state => STATE_NETWORK_REVIEW) }
      scope :delay_review, -> { where(:state => STATE_DELAY_REVIEW) }
      scope :approved, -> { where(:state => STATE_APPROVED) }
      scope :rejected, -> { where(:state => STATE_REJECTED) }
      scope :unreplied, -> { where(:state => STATE_IN_REVIEW, :replied_to => false) }
    end

    # Instance methods

    # disallow comments on approved and rejected models
    def allow_comments?
      not(approved? || rejected?)
    end
  end
end
