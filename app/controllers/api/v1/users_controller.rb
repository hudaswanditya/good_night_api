module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show following_sleep_records]

      # GET /api/v1/users
      def index
        users = User.select(:id, :username, :created_at).order(created_at: :desc)
        render json: users
      end

      # GET /api/v1/users/:id
      def show
        render json: @user
      end

      # GET /api/v1/users/:id/following_sleep_records
      def following_sleep_records
        sleep_records = @user.following_sleep_records_last_week.includes(:user).select(:id, :user_id, :clock_in, :clock_out, :created_at)
        render json: sleep_records
      end

      private

      def set_user
        @user = User.select(:id, :username, :created_at).find_by(id: params[:id])
        render json: { error: "User not found" }, status: :not_found unless @user
      end
    end
  end
end
