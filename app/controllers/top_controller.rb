class TopController < ApplicationController
  before_action :authenticate_user, :only => [ :game ]

  def index
  end

  def game
  end
end
