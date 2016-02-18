# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Pages aka Sitemap aka Containers/Payloads
# This should seed the database with the pages which are *required* for the
# proper functioning of the webapp.

# It is important that these seeds remain idempotent, that is we need to be
# able to run seed file without fear of overwriting existing data or creating
# duplicates

# TODO There are many many pages missing currently, but they should be added.
# TODO This code needs to be refactored and moved out of here

def seed_page(file_path)
  path = Pathname.new(File.expand_path("./db/page_seeds#{file_path}.json"))
  document = JSON.parse(File.open(path).read)

  draft_payload_id = document.delete('draft_payload_id')
  draft_payload_attrs = document.delete('draft_payload')

  public_payload_id = document.delete('public_payload_id')
  public_payload_attrs = document.delete('public_payload')

  container = Container.find_by(id: document.fetch('id'))
  return container if container.present?

  Container.transaction do
    container = Container.create!(document)

    if draft_payload_id.present?
      payload = container.create_draft_payload!(
        id: draft_payload_id,
        container_id: container.id,
        json_data: draft_payload_attrs.to_json
      )
      container.draft_payload = payload
    end

    if public_payload_id.present?
      container.create_draft_payload!(
        id: public_payload_id,
        container_id: container.id,
        json_data: public_payload_attrs.to_json
      )
      container.public_payload = payload
    end

    container.save!
  end

  puts "Created seed page for #{file_path}"
  container
end

seed_page '/what-is-gc/our-work/sustainable-development/sdgpioneers'
