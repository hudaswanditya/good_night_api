Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        resources :users, only: [ :index, :show ] do
          member do
            post "follow/:target_user_id", to: "relationships#follow"
            delete "unfollow/:target_user_id", to: "relationships#unfollow"
            get :followers, to: "relationships#followers"
            get :following, to: "relationships#following"
          end

          resources :sleep_records, only: [ :index, :create ] do
            collection do
              post :start_sleep
              patch :stop_sleep
            end
          end
        end
      end
    end
  end
end
