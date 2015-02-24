class Redesign::StaticController < ApplicationController
  def homepage
    content = Redesign::Page.lookup(:homepage, '/')
    @page = Redesign::HomePage.new(content)
  end
end
