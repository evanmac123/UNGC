module ApprovalWorkflow
  STATE_PENDING_REVIEW = 'pending_review'
  STATE_IN_REVIEW = 'in_review'
  STATE_NETWORK_REVIEW = 'network_review'
  STATE_APPROVED = 'approved'
  STATE_REJECTED = 'rejected'
  STATE_REJECTED_MICRO = 'reject_micro'

  EVENT_REVISE = 'revise'
  EVENT_NETWORK_REVIEW = 'network_review'
  EVENT_APPROVE = 'approve'
  EVENT_REJECT = 'reject'
  EVENT_REJECT_MICRO = 'reject_micro'
  
  STAFF_EVENTS = [EVENT_APPROVE, EVENT_REJECT, EVENT_REJECT_MICRO, EVENT_NETWORK_REVIEW]
  
  def self.included(klass)
    klass.class_eval do
      belongs_to :reviewer, :class_name => 'Contact'
      
      determine_initial_state = case klass.to_s
        # COPs start in an initial state, and then move to either submitted ('pending_review', 
        # like other models), or draft. Other models don't support draft states, yet.
        when 'CommunicationOnProgress'
          :initial
        else
          :pending_review
        end
      
      state_machine :state, :initial => determine_initial_state do
        after_transition :on => :approve, :do => :set_approved_fields
        after_transition :on => :reject, :do => :set_rejected_fields
        after_transition :on => :reject_micro, :do => :set_rejected_fields
        after_transition :on => :network_review, :do => :set_network_review
        event :save_as_draft do
          transition :from => :initial, :to => :draft
        end
        event :submit do
          transition :from => [:initial, :draft], :to => :pending_review
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
        event :reject_micro do
          transition :from => [:in_review, :pending_review, :network_review], :to => :rejected
        end
      end

      named_scope :pending_review, :conditions => {:state => STATE_PENDING_REVIEW}
      named_scope :in_review, :conditions => {:state => STATE_IN_REVIEW}
      named_scope :network_review, :conditions => {:state => STATE_NETWORK_REVIEW}
      named_scope :approved, :conditions => {:state => STATE_APPROVED}
      named_scope :rejected, :conditions => {:state => STATE_REJECTED}
      named_scope :reject_micro, :conditions => {:state => STATE_REJECTED_MICRO}
      
      named_scope :unreplied, :conditions => {:replied_to => false}
    end
  end
end