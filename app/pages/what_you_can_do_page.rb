class WhatYouCanDoPage < ContainerPage

  def hero
    {
      title: {
        title1: 'What you can do'
      }
    }
  end

  def actions
    Redesign::Container.action.includes(:public_payload).map { |c| Components::ContentBox.new(c) }
  end

end

