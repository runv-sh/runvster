Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "index.html", to: redirect("/")
  get "www/index.html", to: redirect("/")

  root "posts#index"
  get "top", to: "posts#index", defaults: { tab: "top" }, as: :top_posts
  get "links", to: "posts#index", defaults: { tab: "links" }, as: :link_posts
  get "discussao", to: "posts#index", defaults: { tab: "discussao" }, as: :discussion_posts

  get "sign-up", to: "users#new", as: :sign_up
  get "login", to: "sessions#new", as: :sign_in
  get "sign-in", to: redirect("/login")
  delete "sign-out", to: "sessions#destroy", as: :sign_out

  resource :dashboard, only: :show
  resources :notifications, only: %i[index update]
  resource :session, only: %i[create]
  resources :invitations, only: %i[create]
  resources :moderation_cases, only: %i[create]
  resources :tags, only: :show
  resources :users, path: "u", param: :username, only: %i[new create show]
  resources :posts, only: %i[index show new create] do
    resource :vote, only: %i[create update destroy]
    resources :comments, only: :create
  end

  namespace :admin do
    resources :users, only: %i[index update destroy]
    resources :posts, only: %i[index update destroy]
    resources :comments, only: %i[index update destroy]
    resources :invitations, only: %i[index update destroy]
    resources :moderation_cases, only: %i[index update]
    resources :tags, only: %i[index update destroy]
  end
end
