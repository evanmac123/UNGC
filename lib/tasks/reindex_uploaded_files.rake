desc "ReIndex Uploaded File contents from <cutoff> date."
task :reindex_uploaded_files, [:cutoff] => [:environment] do |t, args|
  unless args.has_key? :cutoff
    raise "usage: reindex_uploaded_files[01-Jul-2013]"
  end

  cutoff = Time.parse(args[:cutoff])

  original_timeout = FileTextExtractor.timeout
  begin
    puts 'stopping sphinx'
    system 'stop_sphinx'

    # disable the timeout
    FileTextExtractor.timeout = 0

    puts 'updating searchables'
    Searchable.index_new_or_updated(cutoff)

    puts 'updating LocalNetworkEvents'
    LocalNetworkEvent.where('created_at >= ?', cutoff).each do |e|
      puts "extracting text from #{e.title}"
      e.extract_attachment_content
      e.save!
    end
  rescue => e
    puts e
  ensure
    puts 'rebuilding sphinx indexes'
    system 'sphinx_rebuild'
    FileTextExtractor.timeout = original_timeout
  end

end
