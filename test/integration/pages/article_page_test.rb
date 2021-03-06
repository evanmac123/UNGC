require 'test_helper'

class ArticlePageTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    create_staff_user

    container = create(:container,
      path: 'new-article-path',
      layout: 'article'
    )
    payload = load_payload(:article)

    payload['widget_contact']['contact_id'] = update_contact_with_image(@staff_user).id
    @resources,payload['resources'] = create_resource_content_block_data_and_payload
    @events, @news, @academies = create_event_news_component_data

    container.create_public_payload(
      container_id: container.id,
      json_data: payload.to_json
    )
    container.save

    get '/new-article-path'

    @data = container.public_payload.data
  end

  should 'respond successfully' do
    assert_response :success
  end

  should 'render meta tags component' do
    assert_render_meta_tags_component @data[:meta_tags]
  end

  should 'render hero component' do
    assert_render_hero_component @data[:hero]
  end

  should 'render header' do
    assert_select '.main-content-header', @data[:article_block][:title]
  end

  should 'render content' do
    assert_select_html '.main-content-body', @data[:article_block][:content]
  end

  should 'render sidebar widgets components' do
    assert_select '.article-sidebar' do
      assert_render_sidebar_contact_component @staff_user
      assert_render_sidebar_call_to_action_component @data[:widget_calls_to_action], 1
      assert_render_sidebar_links_lists_component @data[:widget_links_lists], 2
    end
  end

  should 'render resources through the content blocks component' do
    assert_render_resources_content_block_component @resources
  end

  should 'render events/news component' do
    assert_render_events_news_component events: @events, news: @news, academies: @academies
  end
end
