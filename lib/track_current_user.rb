module TrackCurrentUser
  def self.included(klass)
    klass.class_eval do
      before_create :set_created_by
      before_update :set_updated_by
      belongs_to :created_by, :class_name => 'Contact', :foreign_key => :created_by_id
      belongs_to :updated_by, :class_name => 'Contact', :foreign_key => :updated_by_id
      # include TrackCurrentUser::InstanceMethods
    end
  end

  def set_created_by
    self.created_by ||= @current_contact if @current_contact
  end

  def set_updated_by
    self.updated_by ||= @current_contact if @current_contact
  end

  def as_user(user)
    @current_contact = user
    self # makes chaining possible
  end
end
