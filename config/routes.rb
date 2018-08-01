Rails.application.routes.draw do
  devise_for :users

  get 'top/index'

  get '/game' => 'game#index'

  root "top#index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
