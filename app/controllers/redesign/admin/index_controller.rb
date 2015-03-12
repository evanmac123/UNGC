class Redesign::Admin::IndexController < Redesign::Admin::AdminController
  def frontend
    render text: '', layout: 'redesign/admin'
  end
end
