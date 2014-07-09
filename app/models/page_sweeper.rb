class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  def after_update(page)
    # only expire cache if there are no pending version for the path
    if Page.pending_version_for(page.path).nil?
      unless page.path.nil?
        expire_page(page.path)
        # FIXME for some reason, only a file delete is clearing the cache
        FileUtils.rm(File.join(Rails.root, 'public', page.path), :force => true)
      end
    end
  end

  def after_destroy(page)
    expire_page(page.path)
  end
end
