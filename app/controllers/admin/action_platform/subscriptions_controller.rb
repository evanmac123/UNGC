class Admin::ActionPlatform::SubscriptionsController < AdminController
  before_action :must_be_a_participant, except: :show

  def show
    @order = ::ActionPlatform::Order.find(params.fetch(:id))
  end

  def new
    order = ::ActionPlatform::OrderForm.new(current_params)
    @order = Presenter.new(current_contact, order)
  end

  def create
    order = ::ActionPlatform::OrderForm.new(order_params)
    if order.create
      redirect_to(action: :show, id: order.id)
    else
      @order = Presenter.new(current_contact, order)
      render :new
    end
  end

  class Presenter < SimpleDelegator
    attr_reader :countries

    def initialize(contact, form)
      super(form)
      @contacts = contact.organization.contacts
      @countries = Country.all
    end

    def contacts
      @contacts.map do |c|
        [c.name, c.id]
      end
    end

  end

  private

  private

  def must_be_a_participant
    unless current_contact.organization&.participant_level?
      flash[:error] = I18n.t("notice.must_be_a_participant_to_choose_action_platforms")
      redirect_to dashboard_url
    end
  end

  def current_params
    organization = current_contact.organization
    contact = organization.financial_contact_or_contact_point
    {
      organization: organization,
        financial_contact_id: contact.id,
        revenue: organization.precise_revenue
    }.merge(contact.attributes)
  end

  def order_params
    params.require(:order).permit(
      :accepts_terms_of_use,
      :confirm_financial_contact,
      :revenue,
      :financial_contact_id,
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
      subscriptions: [
        :selected,
        :contact_id,
        :platform_id
      ],
    ).merge(organization: current_contact.organization)
  end

end
