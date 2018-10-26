class GameController < ApplicationController
  before_action :authenticate_user!, :only => [ :game ]

  def index
    unless current_user
      redirect_to "/"
    end
  end
end
