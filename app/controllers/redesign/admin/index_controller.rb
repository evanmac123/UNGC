class Redesign::Admin::IndexController < Redesign::Admin::AdminController
  def ember
    render text: '', layout: 'redesign/admin'
  end
end
