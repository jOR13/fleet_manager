Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      resources :vehicles do
        resources :maintenance_services, only: [ :index, :create ]
      end

      resources :maintenance_services, only: [ :update, :destroy ]

      namespace :reports do
        get :maintenance_summary
      end
    end
  end

  root to: redirect("/#{I18n.default_locale}", status: 302)

  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do
    get "/", to: "vehicles#index", as: "localized_root"
    resources :vehicles do
      resources :maintenance_services, except: [ :show ]
    end
    resources :maintenance_services, only: [ :show, :edit, :update, :destroy ]

    resources :reports, only: [ :index ] do
      collection do
        get :export
      end
    end
  end
end
