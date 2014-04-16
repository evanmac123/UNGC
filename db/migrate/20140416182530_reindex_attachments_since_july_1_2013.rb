class ReindexAttachmentsSinceJuly12013 < ActiveRecord::Migration
  def up
    cutoff = Time.new(2013,7,1)
    begin
      puts 'stopping sphinx'
      system 'stop_sphinx'

      puts 'updating searchables'
      Searchable.index_new_or_updated(cutoff)

      puts 'updating LocalNetworkEvents'
      LocalNetworkEvent.transaction do
        LocalNetworkEvent.where('created_at >= ?', cutoff).each do |e|
          e.extract_attachment_content
          e.save!
        end
      end
    ensure
      puts 'rebuilding sphinx indexes'
      system 'sphinx_rebuild'
    end
  end

  def down
  end
end
