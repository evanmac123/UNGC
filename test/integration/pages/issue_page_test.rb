require 'test_helper'

class IssuePageTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    create_staff_user

    container = create(:container,
      path: 'new-issue-path',
      layout: 'issue'
    )
    payload = load_payload(:issue)

    payload['widget_contact']['contact_id'] = update_contact_with_image(@staff_user).id
    @related_contents = create_related_contents_component_data
    @resources,payload['resources'] = create_resource_content_block_data_and_payload
    @events, @news, @academies = create_event_news_component_data

    container.create_public_payload(
      container_id: container.id,
      json_data: payload.to_json
    )
    container.save

    get '/new-issue-path'

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

  should 'render tied principles component' do
    assert_render_tied_principles_component @data[:principles], 1
  end

  should 'render header' do
    assert_select '.main-content-header', @data[:issue_block][:title]
  end

  should 'render content' do
    assert_select_html '.main-content-body-content', @data[:issue_block][:content]
  end

  should 'render sidebar widgets component' do
    assert_select '.article-sidebar' do
      assert_render_sidebar_contact_component @staff_user
      assert_render_sidebar_call_to_action_component @data[:widget_calls_to_action], 2
      assert_render_sidebar_links_lists_component @data[:widget_links_lists], 1
    end
  end

  should 'render related contents through the content blocks component' do
    assert_render_related_contents_content_block_component @related_contents
  end

  should 'render resources through the content blocks component' do
    assert_render_resources_content_block_component @resources
  end

  should 'render events/news component' do
    assert_render_events_news_component events: @events, news: @news, academies: @academies
  end
end
