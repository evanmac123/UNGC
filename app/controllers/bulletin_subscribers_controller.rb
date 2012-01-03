class BulletinSubscribersController < ApplicationController
  helper :cops, :navigation, :pages
  before_filter :determine_navigation

  def new
    @bulletin_subscriber = BulletinSubscriber.new
  end

  def create
    @bulletin_subscriber = BulletinSubscriber.new(params[:bulletin_subscriber])
    if params[:commit] == 'Subscribe'
      subscribe
    else
      unsubscribe
    end
  end

  private
    def default_navigation
      '/NewsAndEvents/UNGC_bulletin/index.html'
    end

    def subscribe
      if @bulletin_subscriber.save
        flash[:notice] = 'You have been subscribed to the Bulletin.'
        redirect_to new_bulletin_subscriber_path
      else
        flash[:error] = 'Please enter a valid email address.'
        render :action => 'new'
      end
    end

    def unsubscribe
      bulletin_subscriber = BulletinSubscriber.find_by_email params[:bulletin_subscriber][:email]
      if bulletin_subscriber
        bulletin_subscriber.destroy
        flash[:notice] = 'You have been unsubscribed from the Bulletin.'
        redirect_to new_bulletin_subscriber_path
      else
        flash[:error] = 'Sorry, we could not find that email address.'
        render :action => 'new'
      end
    end
end
