module ActionPlatform
  class OrderForm
    include Virtus.model
    include ActiveModel::Validations

    attr_accessor :order_service

    attribute :accepts_terms_of_use, Boolean
    attribute :confirm_financial_contact, Boolean
    attribute :subscriptions, Hash[Integer, SubscriptionForm], default: {}
    attribute :revenue, MoneyType

    attribute :organization, Organization

    attribute :financial_contact_id, Integer
    attribute :prefix, String
    attribute :first_name, String
    attribute :middle_name, String
    attribute :last_name, String
    attribute :job_title, String
    attribute :email, String
    attribute :phone, String
    attribute :fax, String
    attribute :address, String
    attribute :address_more, String
    attribute :city, String
    attribute :state, String
    attribute :postal_code, String
    attribute :country_id, String

    validates :accepts_terms_of_use, presence: true
    validates :confirm_financial_contact, presence: true
    validates :financial_contact_id, presence: true
    validates :prefix, presence: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :job_title, presence: true
    validates :email, presence: true
    validates :phone, presence: true
    validates :address, presence: true
    validates :city, presence: true
    validates :country_id, presence: true

    validate :validate_subscriptions

    def initialize(params = {})
      super(params)
      @platforms = Platform.available_for_signup
      @order_service = OrderService
    end

    def platforms_with_subscriptions
      @platforms.map do |platform|
          [
            platform,
              subscriptions.fetch(platform.id) {
                SubscriptionForm.new(platform_id: platform.id)
            }
          ]
      end
    end

    def create
      return false unless valid?

      @order = Organization.transaction do
        update_organization_revenue
        contact = update_financial_contact
        create_order(contact)
      end

      true
    end

    def id
      @order.id
    end

    private

    def update_organization_revenue
      if revenue.present?
        organization.update!(precise_revenue: revenue)
      end
    end

    def update_financial_contact
      contact = organization.contacts.find(financial_contact_id)
      contact.update!(attributes.slice(
        :prefix,
        :first_name,
        :middle_name,
        :last_name,
        :job_title,
        :email,
        :phone,
        :fax,
        :address,
        :address_more,
        :city,
        :state,
        :postal_code,
        :country_id,
      ))
      contact
    end

    def create_order(contact)
      service = @order_service.new(organization, contact)
      selected_subscriptions.each do |subscription|
        service.subscribe(
          contact_id: subscription.contact_id,
          platform_id: subscription.platform_id,
        )
      end
      service.create_order
    end

    def selected_subscriptions
      subscriptions.values.select(&:selected)
    end

    def validate_subscriptions
      if selected_subscriptions.empty?
        errors.add(:subscriptions, "You must select at least one platform")
      end

      selected_subscriptions.each do |subscription|
        if subscription.contact_id.blank?
          errors.add(:subscriptions, "A contact must be provided for each Action Platform selected")
        end
      end
    end
  end
end
