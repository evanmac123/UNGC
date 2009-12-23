module ApprovalWorkflow
  STATE_PENDING_REVIEW = 'pending_review'
  STATE_IN_REVIEW = 'in_review'
  STATE_NETWORK_REVIEW = 'network_review'
  STATE_APPROVED = 'approved'
  STATE_REJECTED = 'rejected'

  EVENT_REVISE = 'revise'
  EVENT_REJECT = 'reject'
  EVENT_APPROVE = 'approve'
  
  def self.included(klass)
    klass.class_eval do
      belongs_to :reviewer, :class_name => 'Contact'
      
      state_machine :state, :initial => :pending_review do
        after_transition :on => :approve, :do => :set_approved_fields
        after_transition :on => :network_review, :do => :set_network_review_date
        event :save_as_draft do
          transition :from => :pending_review, :to => :draft
        end
        event :submit do
          transition :from => :draft, :to => :pending_review
        end
        event :revise do
          transition :from => :pending_review, :to => :in_review
        end
        event :network_review do
          transition :from => [:in_review, :pending_review], :to => :network_review
        end
        event :approve do
          transition :from => [:in_review, :pending_review, :network_review], :to => :approved
        end
        event :reject do
          transition :from => [:in_review, :pending_review, :network_review], :to => :rejected
        end
      end

      named_scope :pending_review, :conditions => {:state => STATE_PENDING_REVIEW}
      named_scope :in_review, :conditions => {:state => STATE_IN_REVIEW}
      named_scope :network_review, :conditions => {:state => STATE_NETWORK_REVIEW}
      named_scope :approved, :conditions => {:state => STATE_APPROVED}
      named_scope :rejected, :conditions => {:state => STATE_REJECTED}

      named_scope :unreplied, :conditions => {:replied_to => false}
    end
  end
end