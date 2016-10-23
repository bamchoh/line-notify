Rails.application.routes.draw do
  get 'oauth/index'

  post 'oauth/callback'

  post 'oauth/authorize'

  post 'oauth/send_message'

  get 'oauth/authorize' => "oauth#get_authorize"

  get 'oauth/callback' => "oauth#index"

	get 'oauth/send_message' => "oauth#get_send_message"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
