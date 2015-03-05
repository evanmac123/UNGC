require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  def initialize(*args)
    super(*args)
    create_organization_type
    create_organization
  end

  should "tag event with author" do
    author = create_author
    event = create_event
    tagging = Tagging.create! author: author, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, event
  end

  should "tag headline with author" do
    author = create_author
    headline = create_headline
    tagging = Tagging.create! author: author, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, headline
  end

  should "tag organization with author" do
    author = create_author
    organization = create_organization
    tagging = Tagging.create! author: author, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with author" do
    author = create_author
    redesign_container = create_container
    tagging = Tagging.create! author: author, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with author" do
    author = create_author
    resource = create_resource
    tagging = Tagging.create! author: author, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, resource
  end

  should "tag container with author" do
    author = create_author
    container = create_container
    tagging = Tagging.create! author: author, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with topic" do
    topic = create_topic
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! principle: topic, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with topic" do
    topic = create_topic
    event = create_event
    tagging = Tagging.create! principle: topic, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, event
  end

  should "tag headline with topic" do
    topic = create_topic
    headline = create_headline
    tagging = Tagging.create! principle: topic, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, headline
  end

  should "tag organization with topic" do
    topic = create_topic
    organization = create_organization
    tagging = Tagging.create! principle: topic, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with topic" do
    topic = create_topic
    redesign_container = create_container
    tagging = Tagging.create! principle: topic, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with topic" do
    topic = create_topic
    resource = create_resource
    tagging = Tagging.create! principle: topic, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, resource
  end

  should "tag container with topic" do
    topic = create_topic
    container = create_container
    tagging = Tagging.create! principle: topic, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with principle" do
    principle = create_principle
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! principle: principle, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with principle" do
    principle = create_principle
    event = create_event
    tagging = Tagging.create! principle: principle, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, event
  end

  should "tag headline with principle" do
    principle = create_principle
    headline = create_headline
    tagging = Tagging.create! principle: principle, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, headline
  end

  should "tag organization with principle" do
    principle = create_principle
    organization = create_organization
    tagging = Tagging.create! principle: principle, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with principle" do
    principle = create_principle
    redesign_container = create_container
    tagging = Tagging.create! principle: principle, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with principle" do
    principle = create_principle
    resource = create_resource
    tagging = Tagging.create! principle: principle, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, resource
  end

  should "tag container with principle" do
    principle = create_principle
    container = create_container
    tagging = Tagging.create! principle: principle, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with principle_area" do
    principle_area = create_principle_area
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! principle: principle_area, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with principle_area" do
    principle_area = create_principle_area
    event = create_event
    tagging = Tagging.create! principle: principle_area, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, event
  end

  should "tag headline with principle_area" do
    principle_area = create_principle_area
    headline = create_headline
    tagging = Tagging.create! principle: principle_area, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, headline
  end

  should "tag organization with principle_area" do
    principle_area = create_principle_area
    organization = create_organization
    tagging = Tagging.create! principle: principle_area, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with principle_area" do
    principle_area = create_principle_area
    redesign_container = create_container
    tagging = Tagging.create! principle: principle_area, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with principle_area" do
    principle_area = create_principle_area
    resource = create_resource
    tagging = Tagging.create! principle: principle_area, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, resource
  end

  should "tag container with principle_area" do
    principle_area = create_principle_area
    container = create_container
    tagging = Tagging.create! principle: principle_area, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with country" do
    country = create_country
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! country: country, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with country" do
    country = create_country
    event = create_event
    tagging = Tagging.create! country: country, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, event
  end

  should "tag headline with country" do
    country = create_country
    headline = create_headline
    tagging = Tagging.create! country: country, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, headline
  end

  should "tag organization with country" do
    country = create_country
    organization = create_organization
    tagging = Tagging.create! country: country, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with country" do
    country = create_country
    redesign_container = create_container
    tagging = Tagging.create! country: country, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with country" do
    country = create_country
    resource = create_resource
    tagging = Tagging.create! country: country, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, resource
  end

  should "tag container with country" do
    country = create_country
    container = create_container
    tagging = Tagging.create! country: country, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with initiative" do
    initiative = create_initiative
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! initiative: initiative, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with initiative" do
    initiative = create_initiative
    event = create_event
    tagging = Tagging.create! initiative: initiative, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, event
  end

  should "tag headline with initiative" do
    initiative = create_initiative
    headline = create_headline
    tagging = Tagging.create! initiative: initiative, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, headline
  end

  should "tag organization with initiative" do
    initiative = create_initiative
    organization = create_organization
    tagging = Tagging.create! initiative: initiative, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with initiative" do
    initiative = create_initiative
    redesign_container = create_container
    tagging = Tagging.create! initiative: initiative, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with initiative" do
    initiative = create_initiative
    resource = create_resource
    tagging = Tagging.create! initiative: initiative, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, resource
  end

  should "tag container with initiative" do
    initiative = create_initiative
    container = create_container
    tagging = Tagging.create! initiative: initiative, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with language" do
    language = create_language
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! language: language, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with language" do
    language = create_language
    event = create_event
    tagging = Tagging.create! language: language, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, event
  end

  should "tag headline with language" do
    language = create_language
    headline = create_headline
    tagging = Tagging.create! language: language, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, headline
  end

  should "tag organization with language" do
    language = create_language
    organization = create_organization
    tagging = Tagging.create! language: language, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with language" do
    language = create_language
    redesign_container = create_container
    tagging = Tagging.create! language: language, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with language" do
    language = create_language
    resource = create_resource
    tagging = Tagging.create! language: language, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, resource
  end

  should "tag container with language" do
    language = create_language
    container = create_container
    tagging = Tagging.create! language: language, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, container
  end

  should "tag communication_on_progress with sector" do
    sector = create_sector
    communication_on_progress = create_communication_on_progress
    tagging = Tagging.create! sector: sector, communication_on_progress: communication_on_progress
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, communication_on_progress
  end

  should "tag event with sector" do
    sector = create_sector
    event = create_event
    tagging = Tagging.create! sector: sector, event: event
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, event
  end

  should "tag headline with sector" do
    sector = create_sector
    headline = create_headline
    tagging = Tagging.create! sector: sector, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, headline
  end

  should "tag organization with sector" do
    sector = create_sector
    organization = create_organization
    tagging = Tagging.create! sector: sector, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with sector" do
    sector = create_sector
    redesign_container = create_container
    tagging = Tagging.create! sector: sector, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, redesign_container
  end

  should "tag resource with sector" do
    sector = create_sector
    resource = create_resource
    tagging = Tagging.create! sector: sector, resource: resource
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, resource
  end

  should "tag container with sector" do
    sector = create_sector
    container = create_container
    tagging = Tagging.create! sector: sector, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, container
  end

end
