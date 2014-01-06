class GraceLettersController < ApplicationController
  before_filter :determine_navigation

  def show
    grace_letter = CommunicationOnProgress.find(params[:id])
    @grace_letter = GraceLetterPresenter.new(grace_letter, current_contact)
  end
end
