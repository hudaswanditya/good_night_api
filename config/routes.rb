Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [ :index, :show ] do
    resources :sleep_records, only: [ :index ] do
      collection do
        post :start_sleep  # POST /users/:user_id/sleep_records/start_sleep
        patch :stop_sleep  # PATCH /users/:user_id/sleep_records/stop_sleep
      end
    end
  end
end
