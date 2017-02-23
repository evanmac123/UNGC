require "test_helper"

class Crm::SalesforceTest < ActiveSupport::TestCase

  test "delegates #create! to the client" do
    type = "Account"
    params = { "Name" => "Test" }
    client.expects(:create!).with(type, params).returns(:ok)
    assert_equal :ok, client.create!(type, params)
  end

  test "delegates #query to the client" do
    query = "select Id from Account where AccountNumber = '12345"
    client.expects(:query).with(query).returns(:ok)
    assert_equal :ok, client.query(query)
  end

  test "delegates #find(type, id) to the client" do
    type = "Account"
    id = "12345"
    client.expects(:find).with(type, id).returns(:ok)
    assert_equal :ok, client.find(type, id)
  end

  test "delegates #find(type, value, field_name) to the client" do
    type = "Account"
    email = "test@example.com"
    field = "Email"
    client.expects(:find).with(type, email, field).returns(:ok)
    assert_equal :ok, client.find(type, email, field)
  end

  test "delegates #update! to the client" do
    type = "Account"
    params = { "Name" => "Test" }
    client.expects(:update!).with(type, params).returns(:ok)
    assert_equal :ok, client.update!(type, params)
  end

  test "delegates #destroy! to the client" do
    type = "Account"
    id = "12345"
    client.expects(:destroy!).with(type, id).returns(:ok)
    assert_equal :ok, client.destroy!(type, id)
  end

  private

  def client
    @_client ||= mock("salesforce-client")
  end

  def salesforce
    @_salesforce ||= Crm::Salesforce.new(client)
  end

end
