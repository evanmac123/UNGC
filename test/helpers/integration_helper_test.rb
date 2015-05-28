module IntegrationHelperTest
  def load_payload(type)
    filename = case type
    when :article
      'article_with_all_data.json'
    when :issue
      'issue_with_all_data.json'
    else
      return nil
    end

    JSON.parse(File.read(Rails.root + 'test/fixtures/pages/'+filename))
  end

  def assert_render_meta_tags_component(equality)
    assert_select 'title', equality[:title] + ' | UN Global Compact'
    assert_select "meta[name=description]", :content => equality[:description]
    assert_select "meta[name=keywords]", :content => equality[:keywords]
  end

  def assert_render_hero_component(equality)
    assert_select '#hero' do
      assert_select 'h1', Regexp.new(Regexp.escape(equality[:title][:title1])+'\s+'+Regexp.escape(equality[:title][:title2]))
      assert_select 'p.blurb', equality[:blurb]
      assert_select 'nav#section-nav'
    end
  end

  def assert_render_tied_principles_component
    assert_select '.component-tied-principles' do
      assert_select '.component-tied-principles-label', 'Tied to Principles:'
      assert_select '.component-tied-principle', 1 do
        assert_select '.component-tied-principle-number', '10'
        assert_select '.component-tied-principle-detail', /Businesses should work against corruption in all its forms, including extortion and bribery\.\s+ More about Principle 10/
      end
    end
  end

  def assert_render_sidebar_contact_component(equality)
    assert_select ' .widget-contact', 1 do
      assert_select 'h1', 'Contact'
      assert_select 'img'
      assert_select '.name', equality.prefix + ' ' + equality.name
      assert_select '.title', equality.job_title
      assert_select '.email', equality.email
      assert_select '.phone', equality.phone
    end
  end

  def assert_render_sidebar_call_to_action_component(equality, count)
    assert_select '.widget-call-to-action', count do |calls|
      calls.each_with_index do |call, index|
        href = call.attributes['href'].value.sub('/redesign','')

        assert_equal equality[index][:label], call.content
        assert_equal equality[index][:url], href
      end
    end
  end

  def assert_render_sidebar_links_lists_component(equality, count)
    assert_select '.widget-links-list', count do |links_lists|
      links_lists.each_with_index do |links_list, list_index|
        assert_select links_list, 'h1', equality[list_index][:title]
        assert_select links_list, '.links-list-link-item' do |link_items|
          link_items.each_with_index do |link_item, link_index|
            assert_equal equality[list_index][:links][link_index][:label], link_item.content
            # FIXME: Use assert_equal once links no longer have '/redesign' prepended to them.
            assert_match Regexp.new(Regexp.escape(equality[list_index][:links][link_index][:url])), link_item.attributes['href'].value
          end
        end
      end
    end
  end

  def create_related_contents_component_data
    Array.new(3) do |index|
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
  end

  def assert_render_related_contents_content_block_component(equality)
    assert_select '.component-content-blocks.related-contents' do
      assert_select '.component-header', 'Related Content'
      assert_select '.component-content-block', 3 do |blocks|
        blocks.each_with_index do |block, index|
          assert_select '.component-content-block-link', href: equality[index].path
          assert_select '.component-content-block-image img', src: equality[index].public_payload.data[:meta_tags][:thumbnail] # Passes even though img[src] is empty.
          assert_select '.component-content-block-title', equality[index].public_payload.data[:meta_tags][:title]
          assert_select '.component-content-block-tag', 'No Label'
        end
      end
    end
  end

  def create_resource_content_block_data_and_payload
    payload = []
    resources = Array.new(3) do
      resource = create_resource
      payload << { resource_id: resource.id }

      resource
    end

    [resources,payload]
  end

  def assert_render_resources_content_block_component(equality)
    assert_select '.component-content-blocks.resources' do
      assert_select '.component-header', 'From our Library'
      assert_select '.component-content-block', 3 do |blocks|
        blocks.each_with_index do |block, index|
          assert_select '.component-content-block-link', href: redesign_library_resource_path(equality[index])
          assert_select '.component-content-block-image img', src: equality[index].cover_image # Note: This is /images/original/missing.png during test.
          assert_select '.component-content-block-title', equality[index].title
          assert_select '.component-content-block-tag', equality[index].content_type # Note: This is nil during test.
        end
      end
    end
  end

  def create_event_news_component_data
    events = Array.new(3) do
      event = create_event(starts_at: Date.today + 1.month)
      event.approve!
      event
    end

    news = Array.new(3) do
      create_headline
    end

    [events,news]
  end

  def assert_render_events_news_component(equality)
    assert_select '.events-news-component' do
      assert_select 'menu', 1
      assert_select '.events', 1 do
        assert_select '.tab-content-header', 'Events'
        assert_select '.future-events .event', 3 do |events|
          events.each_with_index do |event, index|
            assert_equal event.attributes['href'].value, redesign_event_path(equality[:events][index])
            # assert_select 'time', equality[:events][index].starts_at # Error: assert_select: I don't understand what you're trying to match.
            assert_select 'address', equality[:events][index].full_location
            assert_select 'h2', equality[:events][index].title
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
            assert_equal news_item.attributes['href'].value, redesign_news_path(equality[:news][index])
            # assert_select 'time', equality[:news][index].date # Error: assert_select: I don't understand what you're trying to match.
            assert_select 'address', equality[:news][index].location
            assert_select 'h2', equality[:news][index].title
          end
        end
        assert_select '.events-component-footer', 'View All News' do
          assert_select 'a'
        end
      end
    end
  end
end
