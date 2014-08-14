# encoding: UTF-8

require 'test_helper'

class ContributionLevelTest < ActiveSupport::TestCase

  setup do
    @level_params = [
      description: "Supérieur à EUR 5 Milliards", amount: "€ 15,000+",
      description: "De EUR 1 Milliard à 5 Milliards", amount: "€ 15,000",
      description: "De EUR 250 Millions à 1 Milliard", amount: "€ 10,000",
      description: "De EUR 50 Millions à 250 million", amount: "€ 5,000",
    ]

    network = create_local_network
    @levels = network.contribution_levels

    @levels.level_description = 'Annual sales/revenue'
    @levels.amount_description = 'Annual contribution'

    @level_params.each do |attrs|
      @levels.add(attrs)
    end

    network.save!
    network.reload
  end

  should validate_presence_of :amount
  should validate_presence_of :description
  should validate_presence_of :contribution_levels_info_id

  should "have saved the levels" do
    assert @levels.persisted?
  end

  should "have a contribution level description" do
    assert_equal 'Annual sales/revenue', @levels.level_description
  end

  should "have a contribution amount description" do
    assert_equal 'Annual contribution', @levels.amount_description
  end

  context "levels" do

    should "have descriptions" do
      descriptions = @level_params.map {|l| l[:description]}
      assert_equal descriptions, @levels.map(&:description)
    end

    should "have amounts" do
      amounts = @level_params.map {|l| l[:amount]}
      assert_equal amounts, @levels.map(&:amount)
    end

  end

end
