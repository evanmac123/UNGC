class FindAndDestroyOrphans
  def all_cop_files
    CopFile.all
  end

  def find_all_orphans
    orphan_cops = []
    all_cop_files.each do |file|
      if file.communication_on_progress.nil?
        orphan_cops << file
      end
    end
    orphan_cops
  end

  def destroy_orphans
    find_all_orphans.each do |orphan|
      orphan.destroy
    end
  end
end
