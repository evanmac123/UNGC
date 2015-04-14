class AllIssuePage < ContainerPage

  def issues
    thumb = c.payload.data[:meta_tags][:thumbnail] rescue nil
    title = c.payload.data[:meta_tags][:title] rescue nil
    Redesign::Container.issue.includes(:public_payload).map do |c|
      {
        thumbnail: thumb,
        issue: "no issue",
        url: c.path,
        title: title
      }
    end
  end

end
