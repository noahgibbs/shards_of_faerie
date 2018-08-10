class TopController < ApplicationController
  #before_action :authenticate_user!, :only => [ :game ]

  def index
    if current_user
      return redirect_to :controller => :game, :action => :index
    end
  end

end
