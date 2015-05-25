require 'test_helper'

class ArticlePageTest < ActionDispatch::IntegrationTest
  setup do
    create_staff_user
    login_as @staff_user

    # TODO create container with layout article
    # TODO create payload for container
    #
    @container = create_container({
      path: 'new-article-path',
      layout: 'article'
    })

    data = File.read(Rails.root + 'test/fixtures/pages/article_with_all_data.json')

    @payload = create_payload({
      container_id: @container.id,
      json_data: data
    });


    @container.public_payload = @payload
    @container.save

    visit '/redesign/new-article-path'
  end

  should 'have a hero' do
    # test for hero title
    # test for hero blurb
    # test for section nav
  end

  should 'have content' do
  end

  should 'have sidebar widgets' do
    #links
    # contact
    # callst to action

  end
end
