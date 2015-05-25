require 'test_helper'

class ArticlePageTest < ActionDispatch::IntegrationTest
  setup do
    create_staff_user
    login_as @staff_user

    @container = create_container({
      path: 'new-article-path',
      layout: 'article'
    })

    data = File.read(Rails.root + 'test/fixtures/pages/article_with_all_data.json')
    json = JSON.parse(data)

    json['widget_contact']['contact_id'] = create_contact.id
    json['widget_links_lists'] << {
      title: "Hello World",
      links: [
        {
          label: "Hello World Link",
          url: "//ungcglobalcompact.org/hello-world",
          external: false
        }
      ]
    }
    json['resources'] << {
      resource_id: create_resource.id
    }

    @payload = create_payload({
      container_id: @container.id,
      json_data: json.to_json
    });

    @container.public_payload = @payload
    @container.save

    get '/redesign/new-article-path'
  end

  should 'respond successfully' do
    assert_response :success
  end

  should 'have a meta tags' do
    assert_select 'title', Regexp.new(Regexp.escape(@payload.data[:article_block][:title]))
    assert_select "meta[name=description]", :content => Regexp.new(Regexp.escape(@payload.data[:meta_tags][:description]))
    assert_select "meta[name=keywords]", :content => Regexp.new(Regexp.escape(@payload.data[:meta_tags][:keywords]))
  end

  should 'have a hero' do
    assert_select '#hero h1'
    assert_select '#hero p.blurb'
    assert_select '#hero nav#section-nav'
  end

  should 'have content' do
    assert_select('.main-content-body')
  end

  should 'have sidebar widgets' do
    assert_select 'aside.article-sidebar'
    assert_select 'aside.article-sidebar .widget-contact'
    assert_select 'aside.article-sidebar .widget-call-to-action'
    assert_select 'aside.article-sidebar .widget-links-list'
  end

  should 'have content blocks' do
    assert_select '.component-content-blocks'
  end

  should 'have event news' do
    assert_select '.events-news-component'
  end
end
