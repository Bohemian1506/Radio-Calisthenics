Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  # スタンプカード機能
  resources :stamp_cards, only: [ :index, :create ]

  # 統計機能
  resources :statistics, only: [ :index ] do
    collection do
      get :monthly
      get :yearly
    end
  end

  # 管理者機能
  namespace :admin do
    root "dashboard#index"
    get "settings", to: "settings#index"
    patch "settings", to: "settings#update"
    resources :users, only: [ :index, :show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
