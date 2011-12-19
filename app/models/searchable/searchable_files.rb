module Searchable::SearchableFiles
  
  def timestamps_from(system_path_to_file)
    if system_path_to_file
      object = OpenStruct.new
      mtime = File.mtime(system_path_to_file)
      object.created_at, object.updated_at = mtime, mtime
      object
    end
  end
  
  def index_pdf(system_path_to_file, public_path_to_file)
    title = 'PDF File'
    url   = public_path_to_file
    content = get_text_from_pdf(system_path_to_file)
    object  = timestamps_from(system_path_to_file)
    import 'PDF', url: url, title: title, content: content, object: object
  end

end
