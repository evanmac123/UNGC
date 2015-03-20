require 'test_helper'

class NewsControllerTest < ActionController::TestCase

  context "generated" do

    setup do
      @latest = create_headline_for(year(2014))
      @oldest = create_headline_for(year(2013))
    end

    should "#index" do
      get :index
      headlines = assigns(:headlines)
      assert_equal 2, headlines.count
    end

    should "#index by year" do
      get :index, year: 2013
      headlines = assigns(:headlines)
      assert_equal [@oldest.id], headlines.map(&:id)
    end

    should "atom feed" do
      get :index, format: :atom
      assert_not_nil assigns(:headlines)
      assert_match Regexp.new("tag:test.host,2005:Headline\/#{@latest.id}"), response.body
    end

    should "show archived headlines" do
      get :show, permalink: @latest.to_param

      assert_not_nil assigns(:headline)
      nav = @controller.send(:default_navigation)
      assert_equal DEFAULTS[:news_archive_path], nav
    end

    should "show recent headlines" do
      headline = create_headline_for(Date.today)
      get :show, permalink: headline.to_param

      assert_not_nil assigns(:headline)
      nav = @controller.send(:default_navigation)
      assert_equal DEFAULTS[:news_headlines_path], nav
    end

    should "redirect to the home page for invalid headlines" do
      get :show, permalink: 12345
      assert_redirected_to '/'
    end

    should "redirect to the permalink url if not given" do
      get :show, permalink: @latest.id
      assert_redirected_to headline_path(@latest)
    end

  end

  private

  def create_headline_for(publish_date)
    headline = create_headline description: '<p>test</p>', published_on: publish_date
    headline.approve!
    headline
  end

  def year(y)
    Date.new(y, 1, 1)
  end

end
