class HighlightPage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def article_blocks
    @data[:article_blocks].map do |article|
      data = {
        title: article[:title],
        content: article[:content],
        align: article[:align],
        bg_image: article[:bg_image],
        theme: article[:theme]
      }
      image = article[:widget_image]
      if image
        data[:widgets] = {
          image: image
        }
        data[:widgets][:image][:type] = 'image'
      end
      data
    end
  end
end
