Rails.application.routes.draw do


  get '/health', to: 'application#health', format: true

  post '/signin', to: 'users#authenticate', format: true
  post '/signup', to: 'users#register', format: true

  get '/users/list', to: 'users#index', format: true
  
  post '/users', to: 'users#create', format: true
  get '/users/:id', to: 'users#show', format: true
  put '/users/:id', to: 'users#update', format: true
  delete '/users/:id', to: 'users#destroy', format: true
  

  match '/:asterisk', via: [:options], constraints: { asterisk: /.*/ }, to: 'application#handle_cors_options'
end
