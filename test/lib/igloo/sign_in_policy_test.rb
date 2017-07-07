require 'test_helper'

module Igloo
  class IglooContactsQueryTest < ActiveSupport::TestCase

    test "responds no when no eligible contacts are present" do
      contact = create(:contact)
      policy = Igloo::SignInPolicy.new
      refute policy.can_sign_in?(contact), "This contact should not have been allowed to sign in."
    end

    test "queries are tried in order" do
      contact = create(:contact)

      log = []
      policy = Igloo::SignInPolicy.new(queries: [
        FakeQuery.new(:first, log, false),
        FakeQuery.new(:second, log, false)
      ])

      policy.can_sign_in?(contact)

      assert_equal [:first, :second], log
    end

    test "queries short circuit" do
      contact = create(:contact)

      log = []
      policy = Igloo::SignInPolicy.new(queries: [
        FakeQuery.new(:first, log, true),
        FakeQuery.new(:second, log, false)
      ])

      assert policy.can_sign_in?(contact)
      assert_equal [:first], log
    end

    private

    class FakeQuery
      def initialize(id, log, return_value)
        @id = id
        @log = log
        @return_value = return_value
      end

      def include?(_contact)
        @log << @id
        @return_value
      end
    end

  end
end
