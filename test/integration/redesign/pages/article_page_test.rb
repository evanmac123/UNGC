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

    create_organization_type
    create_country

    @contact = create_contact(
      username: 'UNGC Contact',
      password: 'password',
      organization_id: @ungc.id,
      image: fixture_file_upload('files/untitled.jpg', 'image/jpeg')
    )
    json['widget_contact']['contact_id'] = @contact.id

    @resources = Array.new(3) { create_resource }
    json['resources'] = @resources.map do |resource|
      { resource_id: resource.id }
    end

    @events = Array.new(3) do
      create_event({
        starts_at: Date.today + 1.month,
      })
    end
    @events.each { |event| event.approve! }

    @news = Array.new(3) { create_headline }

    @payload = create_payload({
      container_id: @container.id,
      json_data: json.to_json
    })

    @container.public_payload = @payload
    @container.save

    get '/redesign/new-article-path'
  end

  should 'respond successfully' do
    assert_response :success
  end

  should 'set meta tags' do
    assert_select 'title', Regexp.new(Regexp.escape(@payload.data[:article_block][:title]))
    assert_select "meta[name=description]", :content => @payload.data[:meta_tags][:description]
    assert_select "meta[name=keywords]", :content => @payload.data[:meta_tags][:keywords]
  end

  should 'have a hero' do
    assert_select '#hero' do
      assert_select 'h1', Regexp.new(Regexp.escape(@payload.data[:hero][:title][:title1]))
      assert_select 'h1', Regexp.new(Regexp.escape(@payload.data[:hero][:title][:title2]))
      assert_select 'p.blurb', @payload.data[:hero][:blurb]
      assert_select 'nav#section-nav'
    end
  end

  should 'have content' do
    # XXX: Ugly but it works since assert_select also sanitizes the selection.
    assert_select '.main-content-body', ActionView::Base.full_sanitizer.sanitize(@payload.data[:article_block][:content])
  end

  should 'have sidebar widgets' do
    assert_select '.article-sidebar' do
      assert_select ' .widget-contact' do
        assert_select 'h1', 'Contact'
        assert_select 'img'
        assert_select '.name', @contact.prefix + ' ' + @contact.name
        assert_select '.title', @contact.job_title
        assert_select '.email', @contact.email
        assert_select '.phone', @contact.phone
      end

      assert_select '.widget-call-to-action', 1 do |calls|
        @calls_to_action = @payload.data[:widget_calls_to_action]

        calls.each_with_index do |call, index|
          assert_equal @calls_to_action[index][:label], call.content
          assert_equal '/redesign' + @calls_to_action[index][:url], call.attributes['href'].value
        end
      end

      assert_select '.widget-links-list', 2 do |links_lists|
        @links_lists = @payload.data[:widget_links_lists]

        links_lists.each_with_index do |links_list, index|
          @links_list = @links_lists[index]

          assert_select links_list, 'h1', @links_list[:title]

          assert_select links_list, '.links-list-link-item' do |link_items|
            @link_items = @links_list[:links]

            link_items.each_with_index do |link_item, index|
              @link_item = @link_items[index]

              assert_equal @link_item[:label], link_item.content
              assert_equal '/redesign' + @link_item[:url], link_item.attributes['href'].value
            end
          end
        end
      end
    end
  end

  should 'have content blocks' do
    assert_select '.component-content-blocks' do
      assert_select 'header h1', 'From our Library'
      assert_select '.component-content-block', 3 do |blocks|
        blocks.each_with_index do |block, index|
          @resource = @resources[index]

          assert_select '.component-content-block-link', href: redesign_library_resource_path(@resource)
          assert_select '.component-content-block-image', src: @resource.cover_image # Note: This is /images/original/missing.png during test.
          assert_select '.component-content-block-title', @resource.title
          assert_select '.component-content-block-tag', @resource.content_type # Note: This is nil during test.
        end
      end
    end
  end

  should 'have event news' do
    assert_select '.events-news-component' do
      assert_select 'menu', 1
      assert_select '.events', 1 do
        assert_select '.tab-content-header', 'Events'
        assert_select '.future-events .event', 3 do |events|
          events.each_with_index do |event, index|
            assert_equal event.attributes['href'].value, redesign_event_path(@events[index])
            # assert_select 'time', @events[index].starts_at # Error: assert_select: I don't understand what you're trying to match.
            assert_select 'address', @events[index].full_location
            assert_select 'h2', @events[index].title
          end
        end
        assert_select '.events-component-footer', 'View All Events' do
          assert_select 'a'
        end
      end

      assert_select '.news' do |news|
        assert_select '.tab-content-header', 'News'
        assert_select '.news-items .news-item' do |news_items|
          news_items.each_with_index do |news_item, index|
            assert_equal news_item.attributes['href'].value, redesign_news_path(@news[index])
            # assert_select 'time', @news[index].date # Error: assert_select: I don't understand what you're trying to match.
            assert_select 'address', @news[index].location
            assert_select 'h2', @news[index].title
          end
        end
        assert_select '.events-component-footer', 'View All News' do
          assert_select 'a'
        end
      end
    end
  end
end
