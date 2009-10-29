module ContentApproval
  def self.included(klass)
    klass.class_eval do
      belongs_to :approved_by, :class_name => 'Contact'
      named_scope :approved, :conditions => {:approval => 'approved'}
      state_machine :approval, :initial => 'pending' do
        event(:approve) { transition :from => 'pending',  :to => 'approved'   }
        event(:reject)  { transition :from => 'pending',  :to => 'rejected'   }
        event(:revoke)  { transition :from => 'approved', :to => 'previously' }
        before_transition(:to => 'approved') { |obj| obj.store_approved_data }
        before_transition(:to => 'approved') { |obj| obj.before_approve! if obj.respond_to?(:before_approve!)  }
      end
    end
  end

  def store_approved_data
    self.approved_at = Time.now
    self.approved_by = @current_user if @current_user
  end
end