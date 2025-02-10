Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show] do
        resources :sleep_records, only: [:index, :create] do
          collection do
            post :start_sleep
            patch :stop_sleep
          end
        end
      end
    end
  end
end