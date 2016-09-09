class LibraryDetailPresenter < SimpleDelegator
  def links_list
    self.links.map do |l|
      LinkPresenter.new(l)
    end
  end

  def sustainable_development_goals
    resource.sustainable_development_goals.order('goal_number asc').select(:id, :name)
  end

  private
  def resource
    __getobj__
  end
end

class LinkPresenter

  def initialize(link)
    @link = link
  end

  def title
    @link.title
  end

  def type
    @link.link_type
  end

  def url
    @link.url
  end

  def language
    @link.language.name
  end

  def is_video?
    type == 'video'
  end

  def is_podcast?
    type == 'mp3'
  end

  def id
    @link.id
  end

  def is_youtube?
    if is_video?
      host = URI.parse(url).host
      return host == 'www.youtube.com'
    end
    false
  end

  def video_id
    if is_youtube?
      q = URI.parse(@link.url).query
      return CGI::parse(q)['v'].first if q
    end
    nil
  end

  def embed_url
    if is_youtube?
      "https://www.youtube.com/embed/#{video_id}"
    else
      ''
    end
  end

end
