class GameController < ApplicationController
  #before_action :authenticate_user!, :only => [ :game ]

  def index
    current_or_guest_user
  end
end
