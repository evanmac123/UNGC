module NewsHelper
  def headlines
    Headline.recent
  end
end
