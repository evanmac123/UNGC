require 'test_helper'

class ListPageTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    create_staff_user

    container = create_container(
      path: 'new-list-path',
      layout: 'list'
    )
    payload = load_payload(:list)

    container.create_public_payload(
      container_id: container.id,
      json_data: payload.to_json
    )
    container.save

    get '/new-list-path'

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
    assert_select '.main-content-header', @data[:list_block][:title]
  end

  should 'render content list' do
    assert_select '.content-list' do
      assert_select_html '.main-content-blurb', @data[:list_block][:blurb]
      assert_select '.content-list-item' do |items|
        items.each_with_index do |item, index|
          assert_select item, '.content-list-item-image[href=?]', @data[:list_block][:items][index][:url]
          assert_select item, '.content-list-item-image img[alt=?]', @data[:list_block][:items][index][:title]
          assert_select item, '.content-list-item-image img[src=?]', @data[:list_block][:items][index][:image]
          assert_select item, '.content-list-item-content-wrapper' do
            assert_select 'h1 a', @data[:list_block][:items][index][:title]
            assert_select 'h1 a[href=?]', @data[:list_block][:items][index][:url]
            assert_select_html '.blurb', @data[:list_block][:items][index][:blurb]
          end
        end
      end
    end
  end
end
