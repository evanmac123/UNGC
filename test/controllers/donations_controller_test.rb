require "test_helper"

class DonationsControllerTest < ActionController::TestCase

  setup { FakeStripe.stub_stripe }

  test "#new without a contact" do
    get :new

    donation = assigns(:donation)
    assert_nil donation.contact_id
  end

  test "#new with the current contact" do
    # Given I am signed in as an organization contact
    contact, _ = create_contact_and_organization
    sign_in(contact)

    get :new

    donation = assigns(:donation)
    assert_equal contact.id, donation.contact_id
  end

  test "#new with a specified contact" do
    # Given there is a contact
    contact, _ = create_contact_and_organization

    # When I visit the form with his/her ID
    get :new, contact_id: contact.id

    donation = assigns(:donation)
    assert_equal contact.id, donation.contact_id
  end

  test "#new form defaults" do
    # Given I am signed in as an organization contact
    contact, organization = create_contact_and_organization
    sign_in(contact)

    # When I visit the form
    get :new

    # My details are pre-filled for me
    assert_select "#new_donation" do
      # Contact fields
      assert_select "input[name='donation[first_name]'][value=?]", contact.first_name
      assert_select "input[name='donation[last_name]'][value=?]", contact.last_name
      assert_select "input[name='donation[company_name]'][value=?]", organization.name
      assert_select "input[name='donation[address]'][value=?]", contact.address
      assert_select "input[name='donation[address_more]'][value=?]", contact.address_more
      assert_select "input[name='donation[city]'][value=?]", contact.city
      assert_select "input[name='donation[state]'][value=?]", contact.state
      assert_select "input[name='donation[postal_code]'][value=?]", contact.postal_code
      assert_select "input[name='donation[country_name]'][value=?]", contact.country_name
      assert_select "input[name='donation[email_address]'][value=?]", contact.email
      assert_select "input[name='donation[contact_id]'][value=?]", contact.id

      # Stripe fields
      assert_select "input[data-stripe='address_line1'][value=?]", contact.address
      assert_select "input[data-stripe='address_line2'][value=?]", contact.address_more
      assert_select "input[data-stripe='address_city'][value=?]", contact.city
      assert_select "input[data-stripe='address_state'][value=?]", contact.state
      assert_select "input[data-stripe='address_zip'][value=?]", contact.postal_code
      assert_select "input[data-stripe='address_country'][value=?]", contact.country_name
      assert_select "input[data-stripe='number']", ""
      assert_select "input[data-stripe='exp_month']", ""
      assert_select "input[data-stripe='exp_year']", ""
      assert_select "input[data-stripe='name'][value=?]", contact.name
      assert_select "input[data-stripe='cvc']", ""

      # Stripe card fields we don't want to see server side
      assert_select "input[name='donation[number]']", false
      assert_select "input[name='donation[exp_month]']", false
      assert_select "input[name='donation[exp_year]']", false
      assert_select "input[name='donation[name]']", false
      assert_select "input[name='donation[cvc]']", false
    end
  end

  test "shows a successful donation" do
    skip
    post :create, donation: valid_donation_params(amount: "123")

    assert_equal "Your donation of $123.00 has been accepted.", flash[:notice]
  end

  test "shows a failed donation" do
    skip
    post :create, donation: valid_donation_params(amount: "123")

    assert_equal "Your donation of $123.00 has been accepted.", flash[:notice]
  end

  test "donation with missing token" do
    params = valid_donation_params
    assert_not_nil params.delete("token")

    post :create, donation: params

    assert_template :new
    assert_match("We were unable to process your donation", response.body)
  end

  test "donation with missing attributes" do
    post :create, donation: {
      token: "fake-token"
    }

    assert_template :new
    assert_match "Email address can&#39;t be blank", response.body.to_s
  end

  test "company name matches" do
    skip
    organization = create(:business)
    params = valid_donation_params(company_name: organization.name)

    post :create, donation: params
    assigns(:donation)
  end

  test "index links to the new donation form with params" do
    create(:container, path: "/about/foundation", layout: :article,
                       public_payload: create(:payload))
    contact, organization = create_contact_and_organization
    get :index, contact_id: contact.id, organization_id: organization.id

    assert_response :ok
    assert_select ".widget-call-to-action" do |a|
      links = a.map {|cta| cta["href"] }
      assert_includes links, new_donation_path(contact_id: contact.id,
                                               organization_id: organization.id)
    end
  end

  private

  def create_contact_and_organization(contact_params = {}, organization_params = {})
    contact = create(:contact, contact_params.reverse_merge(
      state: "California",
      postal_code: "90210",
      address_more: "Suite 123",
    ))

    organization = if organization_params != nil
                     create(:business, organization_params.reverse_merge(
                       contacts: [contact],
                       revenue: 3
                     ))
                   end
    [contact, organization]
  end

  def valid_donation_params(params = {})
    organization = create(:organization)
    params.stringify_keys.reverse_merge(
      "amount" => params.fetch(:amount, "$1,234,567,890.12"),
      "first_name" => "Marlene",
      "last_name" => "Howe",
      "company_name" => organization.name,
      "organization_id" => organization.id,
      "address" => "80082 Alisa Dale",
      "address_more" => "Suite 123",
      "city" => "Clementinafurt",
      "state" => "California",
      "postal_code" => "90210",
      "country_name" => "Malta",
      "email_address" => "kristofer@cummeratamosciski.biz",
      "token" => "fake-token",
      "invoice_number" => organization.id.to_s+"-abcd1234",
      "credit_card_type" => "visa"
    )
  end

end
