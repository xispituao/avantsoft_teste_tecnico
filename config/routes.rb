Rails.application.routes.draw do
  # Swagger documentation
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API endpoints (sem namespace - conforme requisitos)
  resources :frames, only: %i[create show destroy] do
    resources :circles, only: :create
  end

  resources :circles, only: %i[index update destroy]
end
