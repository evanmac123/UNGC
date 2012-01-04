module Searchable::SearchablePage
  def index_page(page)
    if page.approved? && !page.dynamic_content
      title = page.title
      content = with_helper {strip_tags page.content}
      url = page.path
      unless title.blank? && content.blank?
        import 'Page', url: url, title: title, content: content, object: page
      end
    end
  end

  def index_pages
    Page.approved.each { |page| index_page page }
  end

  def index_pages_since(time)
    Page.approved.find(:all, conditions: new_or_updated_since(time)).each { |page| index_page page }
  end
end
