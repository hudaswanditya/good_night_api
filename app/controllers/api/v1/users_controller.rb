module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show following_sleep_records]

      # GET /api/v1/users
      def index
        page = (params[:page] || 1).to_i
        cache_key = "users_list_page_#{page}"

        users = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
          User.select(:id, :username, :created_at)
              .order(created_at: :desc)
              .offset((page - 1) * 50)
              .limit(50)
        end

        render_success("Users retrieved successfully", users)
      end

      # GET /api/v1/users/:id
      def show
        cache_key = "user_#{params[:id]}"
        @user = Rails.cache.read(cache_key)

        if @user.nil?
          BatchUserLookupJob.perform_async([ params[:id] ])
          return render_error("User not found", [ "User does not exist" ], :not_found)
        end

        render_success("User retrieved successfully", @user)
      end

      # GET /api/v1/users/:id/following_sleep_records
      def following_sleep_records
        cache_key = "user_#{@user.id}_following_sleep_records"

        sleep_records = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          @user.following_sleep_records_last_week
               .includes(:user)
               .select(:id, :user_id, :clock_in, :clock_out, :created_at)
               .limit(100)
               .map { |r| { id: r.id, user_id: r.user_id, clock_in: r.clock_in, clock_out: r.clock_out, created_at: r.created_at } }
               .to_json
        end

        render_success("Following sleep records retrieved successfully", JSON.parse(sleep_records))
      end

      private

      def set_user
        @user = Rails.cache.fetch("user_#{params[:id]}", expires_in: 10.minutes) do
          User.select(:id, :username, :created_at).find_by!(id: params[:id])
        end
      rescue ActiveRecord::RecordNotFound
        render_error("User not found", [ "The requested user does not exist" ], :not_found)
      end

      def render_success(message, data)
        render json: { status: "success", message: message, data: data }, status: :ok
      end

      def render_error(message, errors = [], status = :unprocessable_entity)
        render json: { status: "error", message: message, errors: errors }, status: status
      end
    end
  end
end
