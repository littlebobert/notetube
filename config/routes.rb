Rails.application.routes.draw do
  root to: "pages#home"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :notes, only: [:index, :show, :create, :update] do
    member do
      get 'beautiful_transcript'
      get 'raw_notes'
    end
    put "/tags", to: "notes#create_tag", as: "create_tag"
  end

  devise_for :users, controllers: { sessions: "sessions", registrations: "registrations" }

  get "/generate", to: "notes#create"
end
