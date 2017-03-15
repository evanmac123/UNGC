module ActionPlatform
  class SubscriptionForm
    include Virtus.model
    include ActiveModel::Validations

    attribute :platform_id, Integer
    attribute :contact_id, Integer
    attribute :selected, Boolean

    validates :contact_id, presence: true, if: :selected

    def selects?(platform)
      selected && platform.id == platform_id
    end
  end
end
