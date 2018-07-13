Rails.application.routes.draw do
  root to: redirect('/swagger/dist/index.html?url=/api/api-docs.json')
  resources :people, only: [:index, :create, :update, :destroy]
  post '/people/next', to: 'people#next'
  post '/people/notify', to: 'people#notify'
  post '/people/pass', to: 'people#pass'
end
