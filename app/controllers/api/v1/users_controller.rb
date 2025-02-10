module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show following_sleep_records]

      # GET /api/v1/users
      def index
        users = User.select(:id, :username, :created_at).order(created_at: :desc)
        render_success("Users retrieved successfully", users)
      end

      # GET /api/v1/users/:id
      def show
        render_success("User retrieved successfully", @user)
      end

      # GET /api/v1/users/:id/following_sleep_records
      def following_sleep_records
        sleep_records = @user.following_sleep_records_last_week
                             .includes(:user)
                             .select(:id, :user_id, :clock_in, :clock_out, :created_at)
        render_success("Following sleep records retrieved successfully", sleep_records)
      end

      private

      def set_user
        @user = User.select(:id, :username, :created_at).find_by(id: params[:id])
        return if @user

        render_error("User not found", [ "The requested user does not exist" ], :not_found)
      end

      def render_success(message, data)
        render json: {
          status: "success",
          message: message,
          data: data
        }, status: :ok
      end

      def render_error(message, errors = [], status = :unprocessable_entity)
        render json: {
          status: "error",
          message: message,
          errors: errors
        }, status: status
      end
    end
  end
end
