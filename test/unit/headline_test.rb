# encoding: utf-8
require 'test_helper'

class HeadlineTest < ActiveSupport::TestCase
  context "given an headline with a strange title" do
    setup do
      @headline1 = create_headline :id => 1, :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?'
      @headline2 = create_headline :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?'
    end

    should "create an SEO-friendly permalink" do
      assert_equal "1-what-is-this-t-tall-valid-name-really", @headline1.to_param
    end
    
    should "find headline given a permalink" do
      assert_equal @headline1, Headline.find_by_permalink("1-what-is-this-t-tall-valid-name-really")
    end
  end

  context "given a new headline" do
    setup do
      @headline = Headline.new :title => String.random
      assert @headline.save
    end

    should "start 'pending' approval" do
      assert @headline.pending?
    end
    
    context "and it is approved" do
      setup do
        assert @headline.approve!
      end

      should "should be in 'approved' approval" do
        assert @headline.approved?
      end
      
      should "set published_on" do
        assert_equal Date.today, @headline.published_on
      end
    end
    
  end
  
end
