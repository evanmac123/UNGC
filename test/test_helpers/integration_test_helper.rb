module IntegrationTestHelper
  def load_payload(type)
    filename = case type
    when :article
      'article_with_all_data.json'
    when :issue
      'issue_with_all_data.json'
    when :action_detail
      'action_detail_with_all_data.json'
    when :engage_locally
      'engage_locally_with_all_data.json'
    when :list
      'list_with_all_data.json'
    when :accordion
      'accordion_with_all_data.json'
    else
      return nil
    end

    JSON.parse(File.read(Rails.root + 'test/fixtures/pages/'+filename))
  end

  def assert_select_html(element=nil, selector=nil, equality=nil)
    # FIXME: We've hacked this helper to add the element argument. The way it's written though could be better.
    # Looking at how Rails implements assert_select may be insightful:
    # https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb#L164

    if equality
      # XXX: Equality as HTML must be sanitized because assert_select also sanitizes and removes HTML tags.
      assert_select element, selector, ActionView::Base.full_sanitizer.sanitize(equality)
    else
      selector,equality = [element,selector]
      # XXX: Equality as HTML must be sanitized because assert_select also sanitizes and removes HTML tags.
      assert_select selector, ActionView::Base.full_sanitizer.sanitize(equality)
    end
  end

  def update_contact_with_image(contact)
    contact.update(image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'))
    contact
  end

  def assert_render_meta_tags_component(equality)
    assert_select 'title', equality[:title] + ' | UN Global Compact'
    assert_select "meta[name=description]", :content => equality[:description]
    assert_select "meta[name=keywords]", :content => equality[:keywords]
  end

  def assert_render_hero_component(equality, options = { section_nav: true })
    assert_select '#hero' do
      assert_select 'h1', Regexp.new(Regexp.escape(equality[:title][:title1])+'\s+'+Regexp.escape(equality[:title][:title2]))
      assert_select 'p.blurb', equality[:blurb]
      assert_select 'nav#section-nav' unless options[:section_nav] == false
    end
  end

  def assert_render_tied_principles_component(equality, count)
    assert_select '.component-tied-principles' do
      assert_select '.component-tied-principles-label', 'Tied to Principles:'
      assert_select '.component-tied-principle', count do |principles|
        principles.each_with_index do |principle, index|
          assert_select principle, '.component-tied-principle-number', equality[index][:principle].to_s
        end
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
        assert_equal equality[index][:label], call.content
        assert_equal equality[index][:url], call.attributes['href'].value
      end
    end
  end

  def assert_render_sidebar_links_lists_component(equality, count)
    assert_select '.widget-links-list', count do |links_lists|
      links_lists.each_with_index do |links_list, list_index|
        assert_select links_list, 'h1', equality[list_index][:title] if equality[list_index][:title]
        assert_select links_list, '.links-list-link-item' do |link_items|
          link_items.each_with_index do |link_item, link_index|
            assert_equal equality[list_index][:links][link_index][:label], link_item.content
            assert_equal equality[list_index][:links][link_index][:url], link_item.attributes['href'].value
          end
        end
      end
    end
  end

  def create_related_contents_component_data
    Array.new(3) do |index|
     container = create(:container,
       path: '/related-content/' + (index+1).to_s
     )
     container.public_payload = create(:payload,
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
          assert_select block, '.component-content-block-link[href=?]', equality[index].path
          assert_select block, '.component-content-block-image img[src=?]', equality[index].public_payload.data[:meta_tags][:thumbnail] # Passes even though img[src] is empty.
          assert_select block, '.component-content-block-title', equality[index].public_payload.data[:meta_tags][:title]
          assert_select block, '.component-content-block-tag', 'No Label'
        end
      end
    end
  end

  def create_resource_content_block_data_and_payload
    payload = []
    resources = Array.new(3) do
      resource = create(:resource)
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
          assert_select block, '.component-content-block-link[href=?]', library_resource_path(equality[index])
          assert_select block, '.component-content-block-image img[src=?]', equality[index].cover_image(:show, retina: true) # Note: This is /images/show@2x/missing.png during test due to no image and app/views/components/_resource_block.erb
          assert_select block, '.component-content-block-title', equality[index].title
          assert_select block, '.component-content-block-tag', equality[index].content_type # Note: This is nil during test.
        end
      end
    end
  end

  def create_event_news_component_data
    events = Array.new(3) do
      event = create(:event, starts_at: 1.month.from_now)
      event.approve!
      event
    end

    news = Array.new(3) do
      news_item = create(:headline)
      news_item.approve!
      news_item
    end

    academies = Array.new(3) do
      academy = create(:event, starts_at: 1.month.from_now, is_academy: true)
      academy.approve!
      academy
    end

    [events, news, academies]
  end

  def assert_render_events_news_component(equality)
    assert_select '.events-news-component' do
      assert_select 'menu', 1
      assert_select '.events', 1 do
        assert_select '.tab-content-header', 'Events'
        assert_select '.future-events .event', 3 do |event_nodes|
          event_nodes.each_with_index do |event_node, index|
            event = equality[:events][index]
            assert_equal event_node.attributes['href'].value, event_path(event)
            assert_select event_node, 'time', event.starts_at.strftime('%d-%b-%Y')
            assert_select event_node, 'address', event.full_location
            assert_select event_node, 'h2', event.title
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
            assert_equal news_item.attributes['href'].value, news_path(equality[:news][index])
            assert_select news_item, 'time', equality[:news][index].published_on.strftime('%Y-%m-%d')
            assert_select news_item, 'address', equality[:news][index].location
            assert_select news_item, 'h2', equality[:news][index].title
          end
        end
        assert_select '.events-component-footer', 'View All News' do
          assert_select 'a'
        end
      end

      assert_select '.academy-events' do |academy|
        assert_select '.tab-content-header, Academy'
        assert_select '.future-events .academy' do |event_nodes|
          event_nodes.each_with_index do |event_node, index|
            event = equality[:academies][index]
            assert_equal event_node.attributes['href'].value, event_path(event)
            assert_select event_node, 'time', event.starts_at.strftime('%d-%b-%Y')
            assert_select event_node, 'address', event.full_location
            assert_select event_node, 'h2', event.title
          end
        end
        assert_select '.events-component-footer', 'View All Academy Events' do
          assert_select 'a'
        end
      end
    end
  end

  def create_embedded_participants_table_component_data
    initiative = create(:initiative)

    5.times do
      initiative.signatories.create(
        attributes_for(:organization).merge(
          sector_id: create(:sector).id,
          country_id: create(:country).id
        )
      )
    end

    participants = initiative.signatories

    [participants,initiative.id]
  end

  def assert_render_embedded_participants_table_component(equality)
    assert_select '.component-participants-table-embedded' do
      assert_select '.component-header h1', 'Participants'
      assert_select '.table-embedded tbody tr', 5 do |rows|
        rows.each_with_index do |row, index|
          assert_select row, '.name', equality[index].name
          assert_select row, '.sector', equality[index].sector.name
          assert_select row, '.country', equality[index].country.name
        end
      end
    end
  end

  def assert_render_partners_component(equality)
    assert_select '.component-partners' do
      assert_select '.component-header', 'Our Partners'
      assert_select '.component-partners-list a', 1 do |partners|
        partners.each_with_index do |partner, index|
          assert_equal partner.attributes['href'].value, equality[index][:url]
          assert_equal partner.attributes['target'].value, '_blank' if equality[index][:external]
          assert_select partner, 'img[src=?]', equality[index][:logo]
          assert_select partner, 'img[alt=?]', equality[index][:name]
        end
      end
    end
  end
end
