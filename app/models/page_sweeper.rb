class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  def after_update(page)
    # only expire cache if there are no pending version for the path
    if Page.pending_version_for(page.path).nil?
      expire_page(page.path)
      # FIXME for some reason, only a hard file delete is clearing the cache
      FileUtils.rm File.join(RAILS_ROOT, 'public', page.path)
    end
  end

  def after_destroy(product)
    expire_page(page.path)
  end
end