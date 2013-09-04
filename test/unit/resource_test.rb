require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  should have_and_belong_to_many :principles
  should have_and_belong_to_many :authors
  should have_many :links
  should validate_presence_of :title
  should validate_presence_of :description

  context "resource creation" do
    setup do
      @resource = create_resource
    end

    should "create a resource and set it to the pending state" do
      assert_equal ContentApproval::STATES[:pending], @resource.approval
    end

    should "be approvable" do
      @resource.approve!
      assert_equal ContentApproval::STATES[:approved], @resource.approval
    end
  end

  context "Principles counts" do

    setup do
      @labour, @energy, @education = %w(Labour Energy Education).map do |name|
        create_principle(name:name, reference:name.downcase)
      end
      @resource = create_resource(principles:[@labour, @education])
    end

    should "calculate the principles count on create" do
      assert_equal 2, Resource.with_principles_count.find(@resource.id).principles_count
    end

    should "increment the principles count when a topic is added." do
      @resource.principles << @energy
      assert_equal 3, Resource.with_principles_count.find(@resource.id).principles_count
    end

    should "decrement the principles count when a topic is removed." do
      @resource.principles.destroy(@education)
      assert_equal 1, Resource.with_principles_count.find(@resource.id).principles_count
    end

  end


end
