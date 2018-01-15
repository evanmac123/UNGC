# encoding: utf-8
require 'test_helper'

class HeadlineTest < ActiveSupport::TestCase
  should belong_to :country

  context "given an headline with a strange title" do
    setup do
      @headline1 = create(:headline, :id => 1, :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?')
    end

    should "find headline given a permalink" do
      assert_equal @headline1, Headline.find_by_permalink("1-#{Date.current.strftime('%m/%d/%Y')}")
    end
  end

  context "given a headline being read in an Atom feed" do
    setup do
      @headline = Headline.new :title => Faker::Book.title, :description => "<p>First paragraph</p><p>Second paragraph</p>"
    end
    should "use first paragraph as teaser" do
      assert_equal @headline.teaser, "First paragraph"
    end
  end

  context "given a new headline" do
    setup do
      @headline = Headline.new :title => Faker::Book.title
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
        assert_equal Date.current, @headline.published_on
      end
    end
  end

  context "given a headline with a fixed published date" do
    setup do
      fixed_date = (Date.current << 1).strftime('%m/%d/%Y')
      @headline = Headline.new :title => Faker::Book.title, :published_on_string => fixed_date
      assert @headline.save
      @headline.reload
    end

    should "use fixed date for published_on" do
      expected = (Date.current << 1)
      actual   = @headline.published_on
      assert_equal [expected.month, expected.day], [actual.month, actual.day], 'Published date should match'
    end

    should "create an SEO-friendly permalink" do
      assert_equal "#{@headline.id}-#{@headline.date_for_permalink}", @headline.to_param
    end

    context "and when it's approved" do
      setup do
        @headline.approve!
        @headline.reload
      end

      should "still use fixed date for published_on" do
        expected = (Date.current << 1)
        actual   = @headline.published_on
        assert_equal [expected.month, expected.day], [actual.month, actual.day], 'Published date should match'
      end
    end

  end


  context "given a bunch of headlines, some of which are approved" do
    setup do
      @h1 = create(:headline, :approval => 'approved')
      @h2 = create(:headline, :approval => 'approved')
      @h3 = create(:headline, :approval => 'approved')
      @h4 = create(:headline, :approval => 'approved')
      @h5 = create(:headline, :approval => 'approved')
      @h6 = create(:headline)
      @h7 = create(:headline)
      @h8 = create(:headline)
    end

    should "only find approved headlines using published scope" do
      assert_same_elements [@h1, @h2, @h3, @h4, @h5], Headline.published
    end
  end

  context "given a bunch of headlines, in different years" do
    setup do
      @today = Date.current
      5.times { |i| create(:headline, :published_on => Time.mktime(@today.year, i+1, rand(22)+1).to_date) }
      3.times { |i| create(:headline, :published_on => Time.mktime(@today.year - 1, i+1, rand(22)+1).to_date) }
      2.times { |i| create(:headline, :published_on => Time.mktime(@today.year - 2, i+1, rand(22)+1).to_date) }
    end

    should "find 3 years" do
      years = [@today.year.to_s, (@today.year - 1).to_s, (@today.year - 2).to_s]
      assert_equal years, Headline.years
    end

    should "find 5 headlines for this year" do
      assert_equal 5, Headline.all_for_year(@today.year).count
    end
  end

  test "should reject large invalid url" do
    headline = Headline.new(title: "blah", call_to_action_url: "http://goodlink.com/B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1")
    assert_not headline.valid?
  end
end
