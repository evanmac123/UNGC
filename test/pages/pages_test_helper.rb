module PagesTestHelper

  def create_container_with_payload(path, title, layout: :home, parent: nil)
    c = Container.create({
      slug: path,
      path: path,
      layout: layout,
      parent_container: parent
    })

    p = Payload.create({
      container_id: c.id,
      data: {
        meta_tags: {
          title: title,
          description: 'test_description',
          thumbnail: 'http://img.com/1',
        }
      }
    })

    c.public_payload = p
    c.save
    c
  end
end
