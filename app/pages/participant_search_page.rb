class ParticipantSearchPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small'})
  end

end
