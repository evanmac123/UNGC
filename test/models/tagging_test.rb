require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  setup do
    create(:organization_type)
    create(:organization)
  end

  should "tag headline with author" do
    author = create(:author)
    headline = create(:headline)
    tagging = Tagging.create! author: author, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, headline
  end

  should "tag organization with author" do
    author = create(:author)
    organization = create(:organization)
    tagging = Tagging.create! author: author, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, organization
  end

  should "tag container with author" do
    author = create(:author)
    container = create(:container)
    tagging = Tagging.create! author: author, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, container
  end

  should "tag container with author" do
    author = create(:author)
    container = create(:container)
    tagging = Tagging.create! author: author, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, container
  end

  should "tag event with topic" do
    topic = create(:topic)
    event = create(:event)
    tagging = Tagging.create! topic: topic, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, event
  end

  should "tag headline with topic" do
    topic = create(:topic)
    headline = create(:headline)
    tagging = Tagging.create! topic: topic, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, headline
  end

  should "tag organization with topic" do
    topic = create(:topic)
    organization = create(:organization)
    tagging = Tagging.create! topic: topic, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, organization
  end

  should "tag container with topic" do
    topic = create(:topic)
    container = create(:container)
    tagging = Tagging.create! topic: topic, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, container
  end

  should "tag resource with topic" do
    topic = create(:topic)
    resource = create(:resource)
    tagging = Tagging.create! topic: topic, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, resource
  end

  should "tag event with issue" do
    issue = create(:issue)
    event = create(:event)
    tagging = Tagging.create! issue: issue, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, event
  end

  should "tag headline with issue" do
    issue = create(:issue)
    headline = create(:headline)
    tagging = Tagging.create! issue: issue, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, headline
  end

  should "tag organization with issue" do
    issue = create(:issue)
    organization = create(:organization)
    tagging = Tagging.create! issue: issue, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, organization
  end

  should "tag container with issue" do
    issue = create(:issue)
    container = create(:container)
    tagging = Tagging.create! issue: issue, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, container
  end

  should "tag resource with issue" do
    issue = create(:issue)
    resource = create(:resource)
    tagging = Tagging.create! issue: issue, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, resource
  end

  should "tag headline with principle" do
    principle = create(:principle)
    headline = create(:headline)
    tagging = Tagging.create! principle: principle, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, headline
  end

  should "tag organization with principle" do
    principle = create(:principle)
    organization = create(:organization)
    tagging = Tagging.create! principle: principle, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, organization
  end

  should "tag container with principle" do
    principle = create(:principle)
    container = create(:container)
    tagging = Tagging.create! principle: principle, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, container
  end

  should "tag container with principle" do
    principle = create(:principle)
    container = create(:container)
    tagging = Tagging.create! principle: principle, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, container
  end

  should "tag headline with principle_area" do
    principle_area = create(:principle_area)
    headline = create(:headline)
    tagging = Tagging.create! principle: principle_area, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, headline
  end

  should "tag organization with principle_area" do
    principle_area = create(:principle_area)
    organization = create(:organization)
    tagging = Tagging.create! principle: principle_area, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, organization
  end

  should "tag container with principle_area" do
    principle_area = create(:principle_area)
    container = create(:container)
    tagging = Tagging.create! principle: principle_area, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, container
  end

  should "tag container with principle_area" do
    principle_area = create(:principle_area)
    container = create(:container)
    tagging = Tagging.create! principle: principle_area, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, container
  end

  should "tag headline with country" do
    country = create(:country)
    headline = create(:headline)
    tagging = Tagging.create! country: country, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, headline
  end

  should "tag organization with country" do
    country = create(:country)
    organization = create(:organization)
    tagging = Tagging.create! country: country, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, organization
  end

  should "tag container with country" do
    country = create(:country)
    container = create(:container)
    tagging = Tagging.create! country: country, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, container
  end

  should "tag container with country" do
    country = create(:country)
    container = create(:container)
    tagging = Tagging.create! country: country, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, container
  end

  should "tag headline with initiative" do
    initiative = create(:initiative)
    headline = create(:headline)
    tagging = Tagging.create! initiative: initiative, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, headline
  end

  should "tag organization with initiative" do
    initiative = create(:initiative)
    organization = create(:organization)
    tagging = Tagging.create! initiative: initiative, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, organization
  end

  should "tag container with initiative" do
    initiative = create(:initiative)
    container = create(:container)
    tagging = Tagging.create! initiative: initiative, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, container
  end

  should "tag container with initiative" do
    initiative = create(:initiative)
    container = create(:container)
    tagging = Tagging.create! initiative: initiative, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, container
  end

  should "tag headline with language" do
    language = create(:language)
    headline = create(:headline)
    tagging = Tagging.create! language: language, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, headline
  end

  should "tag organization with language" do
    language = create(:language)
    organization = create(:organization)
    tagging = Tagging.create! language: language, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, organization
  end

  should "tag container with language" do
    language = create(:language)
    container = create(:container)
    tagging = Tagging.create! language: language, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, container
  end

  should "tag container with language" do
    language = create(:language)
    container = create(:container)
    tagging = Tagging.create! language: language, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, container
  end

  should "tag event with sector" do
    sector = create(:sector)
    event = create(:event)
    tagging = Tagging.create! sector: sector, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, event
  end

  should "tag headline with sector" do
    sector = create(:sector)
    headline = create(:headline)
    tagging = Tagging.create! sector: sector, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, headline
  end

  should "tag organization with sector" do
    sector = create(:sector)
    organization = create(:organization)
    tagging = Tagging.create! sector: sector, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, organization
  end

  should "tag container with sector" do
    sector = create(:sector)
    container = create(:container)
    tagging = Tagging.create! sector: sector, container: container
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, container
  end

  should "tag resource with sector" do
    sector = create(:sector)
    resource = create(:resource)
    tagging = Tagging.create! sector: sector, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, resource
  end

  context 'create' do
    context 'sustainable development goal tagging' do
      setup do
        @sdg = create(:sustainable_development_goal)
      end

      should 'support container' do
        @container = create(:container)

        assert_difference 'Tagging.count', 1 do
          @tagging = Tagging.create sustainable_development_goal: @sdg, container: @container
        end

        assert_equal @sdg, @tagging.domain
        assert_equal @container, @tagging.subject
      end

      should 'support event' do
        @event = create(:event)

        assert_difference 'Tagging.count', 1 do
          @tagging = Tagging.create sustainable_development_goal: @sdg, event: @event
        end

        assert_equal @sdg, @tagging.domain
        assert_equal @event, @tagging.subject
      end

      should 'support headline' do
        @headline = create(:headline)

        assert_difference 'Tagging.count', 1 do
          @tagging = Tagging.create sustainable_development_goal: @sdg, headline: @headline
        end

        assert_equal @sdg, @tagging.domain
        assert_equal @headline, @tagging.subject
      end

      should 'support organization' do
        @organization = create(:organization)

        assert_difference 'Tagging.count', 1 do
          @tagging = Tagging.create sustainable_development_goal: @sdg, organization: @organization
        end

        assert_equal @sdg, @tagging.domain
        assert_equal @organization, @tagging.subject
      end

      should 'support resource' do
        @resource = create(:resource)

        assert_difference 'Tagging.count', 1 do
          @tagging = Tagging.create sustainable_development_goal: @sdg, resource: @resource
        end

        assert_equal @sdg, @tagging.domain
        assert_equal @resource, @tagging.subject
      end
    end
  end
end
