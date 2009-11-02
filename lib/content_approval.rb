module ContentApproval
  STATES = {
    :pending    => 'pending',
    :approved   => 'approved',
    :rejected   => 'rejected',
    :previously => 'previously'
  }
  
  EVENTS = {
    :approve => :approve,
    :reject  => :reject,
    :revoke  => :revoke
  }
  
  def self.included(klass)
    klass.class_eval do
      belongs_to :approved_by, :class_name => 'Contact'
      named_scope :approved, :conditions => {:approval => ContentApproval::STATES[:approved]}
      state_machine :approval, :initial => ContentApproval::STATES[:pending] do
        event(ContentApproval::EVENTS[:approve]) { transition :from => ContentApproval::STATES[:pending],  :to => ContentApproval::STATES[:approved]   }
        event(ContentApproval::EVENTS[:reject])  { transition :from => ContentApproval::STATES[:pending],  :to => ContentApproval::STATES[:rejected]   }
        event(ContentApproval::EVENTS[:revoke])  { transition :from => ContentApproval::STATES[:approved], :to => ContentApproval::STATES[:previously] }
        before_transition(:to => ContentApproval::STATES[:approved]) { |obj| obj.store_approved_data }
        before_transition(:to => ContentApproval::STATES[:approved]) { |obj| obj.before_approve! if obj.respond_to?(:before_approve!)  }
      end
    end
  end

  def store_approved_data
    self.approved_at = Time.now
    self.approved_by = @current_user if @current_user
  end
  
  # For convenience
  def revoked?
    previously?
  end
end