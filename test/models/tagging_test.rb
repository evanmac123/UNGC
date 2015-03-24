require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  setup do
    create_organization_type
    create_organization
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

  should "tag container with author" do
    author = create_author
    container = create_container
    tagging = Tagging.create! author: author, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, author
    assert_equal tagging.subject, container
  end

  should "tag headline with topic" do
    topic = create_topic
    headline = create_headline
    tagging = Tagging.create! topic: topic, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, headline
  end

  should "tag organization with topic" do
    topic = create_topic
    organization = create_organization
    tagging = Tagging.create! topic: topic, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with topic" do
    topic = create_topic
    redesign_container = create_container
    tagging = Tagging.create! topic: topic, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, redesign_container
  end

  should "tag container with topic" do
    topic = create_topic
    container = create_container
    tagging = Tagging.create! topic: topic, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, topic
    assert_equal tagging.subject, container
  end

  should "tag headline with issue" do
    issue = create_issue
    headline = create_headline
    tagging = Tagging.create! issue: issue, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, headline
  end

  should "tag organization with issue" do
    issue = create_issue
    organization = create_organization
    tagging = Tagging.create! issue: issue, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with issue" do
    issue = create_issue
    redesign_container = create_container
    tagging = Tagging.create! issue: issue, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, redesign_container
  end

  should "tag container with issue" do
    issue = create_issue
    container = create_container
    tagging = Tagging.create! issue: issue, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, issue
    assert_equal tagging.subject, container
  end

  should "tag headline with issue_area" do
    issue_area = create_issue_area
    headline = create_headline
    tagging = Tagging.create! issue: issue_area, headline: headline
    assert_not_nil tagging
    assert_equal tagging.domain, issue_area
    assert_equal tagging.subject, headline
  end

  should "tag organization with issue_area" do
    issue_area = create_issue_area
    organization = create_organization
    tagging = Tagging.create! issue: issue_area, organization: organization
    assert_not_nil tagging
    assert_equal tagging.domain, issue_area
    assert_equal tagging.subject, organization
  end

  should "tag redesign_container with issue_area" do
    issue_area = create_issue_area
    redesign_container = create_container
    tagging = Tagging.create! issue: issue_area, redesign_container: redesign_container
    assert_not_nil tagging
    assert_equal tagging.domain, issue_area
    assert_equal tagging.subject, redesign_container
  end

  should "tag container with issue_area" do
    issue_area = create_issue_area
    container = create_container
    tagging = Tagging.create! issue: issue_area, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, issue_area
    assert_equal tagging.subject, container
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

  should "tag container with principle" do
    principle = create_principle
    container = create_container
    tagging = Tagging.create! principle: principle, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle
    assert_equal tagging.subject, container
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

  should "tag container with principle_area" do
    principle_area = create_principle_area
    container = create_container
    tagging = Tagging.create! principle: principle_area, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, principle_area
    assert_equal tagging.subject, container
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

  should "tag container with country" do
    country = create_country
    container = create_container
    tagging = Tagging.create! country: country, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, country
    assert_equal tagging.subject, container
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

  should "tag container with initiative" do
    initiative = create_initiative
    container = create_container
    tagging = Tagging.create! initiative: initiative, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, initiative
    assert_equal tagging.subject, container
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

  should "tag container with language" do
    language = create_language
    container = create_container
    tagging = Tagging.create! language: language, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, language
    assert_equal tagging.subject, container
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

  should "tag container with sector" do
    sector = create_sector
    container = create_container
    tagging = Tagging.create! sector: sector, redesign_container: container
    assert_not_nil tagging
    assert_equal tagging.domain, sector
    assert_equal tagging.subject, container
  end

end
