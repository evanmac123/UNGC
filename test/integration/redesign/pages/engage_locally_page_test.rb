require 'test_helper'

class EngageLocallyPageTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    create_staff_user
    login_as @staff_user

    container = create_container(
      path: 'new-engage_locally-path',
      layout: 'engage_locally'
    )
    payload = load_payload(:engage_locally)

    payload['widget_contact']['contact_id'] = update_contact_with_image(@staff_user).id
    @related_contents = create_related_contents_component_data
    @resources,payload['resources'] = create_resource_content_block_data_and_payload
    @events,@news = create_event_news_component_data

    container.create_public_payload(
      container_id: container.id,
      json_data: payload.to_json
    )
    container.save

    get '/redesign/new-engage_locally-path'

    @data = container.public_payload.data
  end

  should 'respond successfully' do
    assert_response :success
  end

  should 'render meta tags component' do
    assert_render_meta_tags_component @data[:meta_tags]
  end

  should 'render hero component' do
    assert_render_hero_component @data[:hero], section_nav: false
  end

  should 'render header' do
    assert_select '.main-content-header', @data[:content_block][:title]
  end

  should 'render content' do
    # XXX: Content must be sanitized because assert_select also sanitizes and removes HTML tags.
    assert_select '.main-content-body-content', ActionView::Base.full_sanitizer.sanitize(@data[:content_block][:content])
  end

  should 'render links list widgets components' do
    links_without_title = [{
      links: [{
        label: 'Find out more about local networks',
        url: '/engage-locally/about-local-networks'
      },{
        label: 'Manage your network',
        url: '/engage-locally/manage'
      }]
    }]
    assert_render_sidebar_links_lists_component links_without_title, 1
  end

  should 'render sidebar widgets components' do
    assert_select '.article-sidebar' do
      assert_render_sidebar_contact_component @staff_user
      assert_render_sidebar_call_to_action_component @data[:widget_calls_to_action], 2
    end
  end

  should 'render related contents through the content blocks component' do
    assert_render_related_contents_content_block_component @related_contents
  end

  should 'render resources through the content blocks component' do
    assert_render_resources_content_block_component @resources
  end

  should 'render events/news component' do
    assert_render_events_news_component events: @events, news: @news
  end
end
