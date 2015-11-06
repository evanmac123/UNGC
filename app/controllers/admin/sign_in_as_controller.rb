class Admin::SignInAsController < AdminController

  # get a list of contacts that the current user can sign-in as
  # this currently only support the autocomplete text field
  def index
    terms = params[:term]
    contacts = if terms.present?
      search_contacts(terms)
    else
      Contact.none
    end

    render json: contacts
  end

  # sign-in as the specified contact
  def create
    target = Contact.find(sign_in_as_id)

    if sign_in_policy.can_sign_in_as?(target)
      sign_in(target)
      redirect_to dashboard_path,
        notice: "You have been signed in as #{target.name}"
    else
      redirect_to dashboard_url(tab: 'sign_in_as_contact_point'),
        notice: 'Unauthorized'
    end
  end

  private

  def sign_in_as_id
    params.fetch(:sign_in_as, {}).fetch(:id)
  end

  def sign_in_policy
    @sign_in_policy ||= SignInPolicy.new(current_contact)
  end

  def search_contacts(terms)
    sign_in_policy.sign_in_targets
      .where("organizations.name like ?", "%#{terms}%")
      .select('contacts.id', 'organizations.name')
      .limit(8)
      .map { |contact| format_for_autocomplete(contact) }
  end

  def format_for_autocomplete(contact)
    {
      id: contact.id,
      label: contact.organization.name,
      value: contact.organization.name,
      contact_name: contact.name
    }
  end

end
