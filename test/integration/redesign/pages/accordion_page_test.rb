require 'test_helper'

class AccordionPageTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    create_staff_user

    container = create_container(
      path: 'new-accordion-path',
      layout: 'accordion'
    )
    payload = load_payload(:accordion)

    payload['widget_contact']['contact_id'] = update_contact_with_image(@staff_user).id

    container.create_public_payload(
      container_id: container.id,
      json_data: payload.to_json
    )
    container.save

    get '/new-accordion-path'

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
    assert_select '.main-content-header', @data[:accordion][:title]
  end

  should 'render blurb' do
    assert_select_html '.main-content-blurb', @data[:accordion][:blurb]
  end

  should 'render accordion' do
    assert_select '.accordion-container > .accordion-item', 2 do |items|
      item_with_content = items[0]
      assert_select item_with_content, '.accordion-item-header', @data[:accordion][:items][0][:title]
      assert_select_html item_with_content, '.accordion-item-content', @data[:accordion][:items][0][:content]
      assert_select item_with_content, '.accordion-child', 0

      item_with_children = items[1]
      assert_select item_with_children, '.accordion-item-header', @data[:accordion][:items][1][:title]
      # TODO: Should we test that a root item's content is not being printed?
      # If so that will require adding a class to the template to allow selection.
      assert_select item_with_children, '.accordion-child', 2 do |child|
        assert_select child[0], '.accordion-child-header', @data[:accordion][:items][1][:children][0][:title]
        assert_select_html child[0], '.accordion-item-content', @data[:accordion][:items][1][:children][0][:content]
        assert_select child[1], '.accordion-child-header', @data[:accordion][:items][1][:children][1][:title]
        assert_select_html child[1], '.accordion-item-content', @data[:accordion][:items][1][:children][1][:content]
      end
    end
  end

  should 'render sidebar widgets components' do
    assert_select '.article-sidebar' do
      assert_render_sidebar_contact_component @staff_user
      assert_render_sidebar_call_to_action_component @data[:widget_calls_to_action], 1
      assert_render_sidebar_links_lists_component @data[:widget_links_lists], 2
    end
  end
end
