Rails.application.routes.draw do
  resources :closets do
    get 'subcategories_for_category/:category_id', on: :collection, to: 'closets#subcategories_for_category'
  end


  root 'weather#index'
  devise_for :users, controllers: {
    # ↓ローカルに追加されたコントローラーを参照する(コントローラー名: "コントローラーの参照先")
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    omniauth_callbacks: "omniauth_callbacks"
  }
  get 'weather', to: 'weather#index', as: :weather
  get 'weather/show', to: 'weather#show', as: :show_weather
  get 'privacy_policy', to: 'static_pages#privacy_policy', as: :privacy_policy
  get 'terms_of_service', to: 'static_pages#terms_of_service', as: :terms_of_service
  post '/closets/analyze_image', to: 'closets#analyze_image'

  namespace :public do
    resources :contacts, only: [:new, :create, :index] do
      collection do
        post 'confirm'
        post 'back'
        get 'done'
      end
    end
  end
end
