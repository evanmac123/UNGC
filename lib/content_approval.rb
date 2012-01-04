module ContentApproval
  STATES = {
    :pending    => 'pending',
    :approved   => 'approved',
    :rejected   => 'rejected',
    :previously => 'previously',
    :deleted    => 'deleted'
  }

  EVENTS = {
    :approve => :approve,
    :delete  => :delete,
    :reject  => :reject,
    :revoke  => :revoke
  }

  def self.included(klass)
    klass.class_eval do
      belongs_to :approved_by, :class_name => 'Contact'
      named_scope :approved, :conditions => {:approval => ContentApproval::STATES[:approved]}
      state_machine :approval, :initial => ContentApproval::STATES[:pending] do
        event(ContentApproval::EVENTS[:approve]) { transition :from => [ContentApproval::STATES[:pending], ContentApproval::STATES[:previously]],  :to => ContentApproval::STATES[:approved]   }
        # event(ContentApproval::EVENTS[:reject])  { transition :from => ContentApproval::STATES[:pending],  :to => ContentApproval::STATES[:rejected]   }
        event(ContentApproval::EVENTS[:revoke])  { transition :from => ContentApproval::STATES[:approved], :to => ContentApproval::STATES[:previously] }
        event(ContentApproval::EVENTS[:delete])  { transition :to => ContentApproval::STATES[:deleted]    }
        before_transition(:to => ContentApproval::STATES[:approved]) { |obj| obj.store_approved_data }
        before_transition(:to => ContentApproval::STATES[:approved]) { |obj| obj.before_approve! if obj.respond_to?(:before_approve!)  }
        after_transition(:to  => ContentApproval::STATES[:approved]) { |obj| obj.after_approve! if obj.respond_to?(:after_approve!)    }
      end
    end
  end

  def store_approved_data
    self.approved_at = Time.now
    self.approved_by = @current_user if @current_user
  end

  def destroy
    delete! # use the state machine
    if respond_to?(:children)
      (children || []).each { |child| child.destroy }
    end
  end

  # For convenience
  def revoked?
    previously?
  end
end
