module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user_with_records, only: %i[index]
      before_action :set_user, only: %i[start_sleep stop_sleep]

      # GET /api/v1/users/:user_id/sleep_records
      def index
        sleep_records = @user.sleep_records.order(created_at: :desc).select(:id, :clock_in, :clock_out, :created_at, :updated_at)

        if sleep_records.any?
          render json: { user: { id: @user.id, username: @user.username }, sleep_records: sleep_records }
        else
          render json: { message: "No sleep records found." }, status: :ok
        end
      end

      # POST /api/v1/users/:user_id/sleep_records/start
      def start_sleep
        service = SleepRecordsService.new(@user)
        result = service.start_sleep
        render json: { message: result[:message] }, status: result[:status]
      end

      # PATCH /api/v1/users/:user_id/sleep_records/stop
      def stop_sleep
        result = SleepRecordsService.new(@user).stop_sleep
        render json: { message: result[:message] }, status: result[:status]
      end

      private

      def set_user_with_records
        @user = User.includes(:sleep_records).select(:id, :username).find_by(id: params[:user_id])
        render json: { error: "User not found" }, status: :not_found unless @user
      end

      def set_user
        @user = User.select(:id, :username).find_by(id: params[:user_id])
        render json: { error: "User not found" }, status: :not_found unless @user
      end
    end
  end
end
