module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user, only: %i[index start_sleep stop_sleep]

      # GET /api/v1/users/:user_id/sleep_records
      def index
        sleep_records = @user.sleep_records
                              .order(created_at: :desc)
                              .select(:id, :clock_in, :clock_out, :created_at, :updated_at)
                              .limit(100) # Add pagination

        json_response(:ok, "Sleep records retrieved successfully", {
          user: { id: @user.id, username: @user.username },
          sleep_records: sleep_records
        })
      end

      # POST /api/v1/users/:user_id/sleep_records/start (Async)
      def start_sleep
        SleepRecordJob.perform_later(@user.id, :start_sleep)
        json_response(:accepted, "Clock-in request received and processing in background.")
      end

      # PATCH /api/v1/users/:user_id/sleep_records/stop (Async)
      def stop_sleep
        SleepRecordJob.perform_later(@user.id, :stop_sleep)
        json_response(:accepted, "Clock-out request received and processing in background.")
      end

      private

      def set_user
        @user = User.select(:id, :username).find_by(id: params[:user_id])
        json_response(:not_found, "User not found") unless @user
      end

      def json_response(status, message, data = nil)
        render json: {
          status: status == :ok ? "success" : status == :accepted ? "processing" : "error",
          message: message,
          data: data
        }, status: status
      end
    end
  end
end
