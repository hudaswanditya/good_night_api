module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user, only: %i[index start_sleep stop_sleep]

      # GET /api/v1/users/:user_id/sleep_records
      def index
        records = @user.sleep_records.includes(:user).order(created_at: :desc)

        if records.any?
          render json: { user: @user, sleep_records: records }
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

      def set_user
        @user = User.find_by(id: params[:user_id])
        render json: { error: "User not found" }, status: :not_found unless @user
      end
    end
  end
end
