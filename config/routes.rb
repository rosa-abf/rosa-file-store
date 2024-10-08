Rails.application.routes.draw do
  namespace :api do
    scope module: :v1, path: 'v1' do
      resources :file_stores, only: %i(index show destroy)
      post 'upload' => 'file_stores#create', as: :create
      get  'check'  => 'file_stores#check',  as: :check
    end
  end

  get '/download/:id' => 'api/v1/file_stores#show', as: :download
  get '/stream_gz/:id' => 'api/v1/stream_gz#show', as: :stream_gz
  root to: 'home#index'
end
