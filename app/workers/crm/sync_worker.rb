module Crm
  class SyncWorker
    include Sidekiq::Worker

    def self.sync(model, action)
      # Smelly, but it'll do for now
      clazz = case
      when model.is_a?(Contact) then Crm::ContactSyncWorker
      when model.is_a?(Organization) then Crm::OrganizationSyncWorker
      when model.is_a?(LocalNetwork) then Crm::LocalNetworkSyncWorker
      when model.is_a?(ActionPlatform::Platform) then Crm::ActionPlatformSyncWorker
      when model.is_a?(ActionPlatform::Subscription) then Crm::ActionPlatformSubscriptionSyncWorker
      else
        raise "No CRM Sync registered for #{model.class}"
      end

      if clazz.respond_to?(action)
        clazz.public_send(action, model)
      else
        raise "Unexpected action #{action}, expecting one of :create, :update, or :destroy"
      end
    end

    def self.create(model)
      if sync_class.should_sync?(model)
        perform_async("create", model.id)
      end
    end

    def self.update(model)
      if sync_class.should_sync?(model)
        fields = model.previous_changes.except("updated_at")
        perform_async("update", model.id, fields)
      end
    end

    def self.destroy(model)
      if sync_class.should_sync?(model)
        perform_async("destroy", model.id)
      end
    end

    def perform(action, id, fields = [])
      case action
      when "create"
        create(id)
      when "update"
        update(id, fields)
      when "destroy"
        destroy(id)
      else
        raise "Unexpected action: #{action}, expected one of: create, update, destroy"
      end
    end

    protected

    def self.sync_class
      raise "#{self} must provide an implementation of self.sync_class"
    end

    def model_class
      raise "#{self} must provide an implementation of model_class"
    end

    def sync_class
      self.class.sync_class
    end

    def create(id)
      model = model_class.find(id)
      sync.create(model)
    end

    def update(id, fields)
      model = model_class.find(id)
      sync.update(model, fields)
    end

    def destroy(id)
      sync.destroy(id)
    end

    private

    def sync
      sync_class.new
    end

  end

end
