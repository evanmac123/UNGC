require 'test_helper'

class IssuePageTest < ActionDispatch::IntegrationTest
  include PageComponentTestHelpers

  setup do
    create_staff_user
    login_as @staff_user

    @container = create_container({
      path: 'new-issue-path',
      layout: 'issue'
    })

    payload = JSON.parse(File.read(Rails.root + 'test/fixtures/pages/issue_with_all_data.json'))

    @contact = create_contact(
      username: 'UNGC Contact',
      password: 'password',
      organization_id: @ungc.id,
      image: fixture_file_upload('files/untitled.jpg', 'image/jpeg')
    )
    payload['widget_contact']['contact_id'] = @contact.id

    @related_containers = Array.new(3) do |index|
      container = create_container(
        path: '/related-content/' + (index+1).to_s
      )
      container.public_payload = create_payload(
        container_id: container.id,
        json_data: {
          meta_tags: {
            title: "Related Content " + (index+1).to_s,
            thumbnail: "//thumbnail.jpg"
          }
        }.to_json
      )
      container.save
      container
    end

    @resources = Array.new(3) do
      create_resource
    end
    payload['resources'] = @resources.map do |resource|
      { resource_id: resource.id }
    end

    @events = Array.new(3) do
      event = create_event(starts_at: Date.today + 1.month)
      event.approve!
      event
    end

    @news = Array.new(3) do
      create_headline
    end

    @payload = create_payload({
      container_id: @container.id,
      json_data: payload.to_json
    })

    @container.public_payload = @payload
    @container.save

    get '/redesign/new-issue-path'
  end

  should 'respond successfully' do
    assert_response :success
  end

  should 'render meta tags component' do
    assert_render_meta_tags_component @payload.data[:meta_tags]
  end

  should 'render hero component' do
    assert_render_hero_component @payload.data[:hero]
  end

  should 'render tied principles component' do
    assert_render_tied_principles_component
  end

  should 'render content' do
    # XXX: Content must be sanitized because assert_select also sanitizes and removes HTML tags.
    assert_select '.main-content-body-content', ActionView::Base.full_sanitizer.sanitize(@payload.data[:issue_block][:content])
  end

  should 'render sidebar widgets component' do
    assert_select '.article-sidebar' do
      assert_render_sidebar_contact_component @contact

      assert_render_sidebar_call_to_action_component @payload.data[:widget_calls_to_action], 2

      assert_render_sidebar_links_lists_component @payload.data[:widget_links_lists], 1
    end
  end

  should 'render related contents through the content blocks component' do
    assert_render_related_contents_content_block_component @related_containers
  end

  should 'render resources through the content blocks component' do
    assert_render_resources_content_block_component @resources
  end

  should 'render events/news component' do
    assert_render_events_news_component events: @events, news: @news
  end
end
