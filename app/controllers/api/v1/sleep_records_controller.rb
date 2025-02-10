module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user_with_records, only: [ :index ]
      before_action :set_user, only: [ :start_sleep, :stop_sleep ]

      # GET /api/v1/users/:user_id/sleep_records
      def index
        sleep_records = @user.sleep_records
                              .order(created_at: :desc)
                              .select(:id, :clock_in, :clock_out, :created_at, :updated_at)

        json_response(:ok, "Sleep records retrieved successfully", {
          user: { id: @user.id, username: @user.username },
          sleep_records: sleep_records
        })
      end

      # POST /api/v1/users/:user_id/sleep_records/start
      def start_sleep
        result = SleepRecordsService.new(@user).start_sleep
        json_response(result[:status], result[:message])
      end

      # PATCH /api/v1/users/:user_id/sleep_records/stop
      def stop_sleep
        result = SleepRecordsService.new(@user).stop_sleep
        json_response(result[:status], result[:message])
      end

      private

      def set_user_with_records
        @user = User.includes(:sleep_records).select(:id, :username).find_by(id: params[:user_id])
        json_response(:not_found, "User not found") unless @user
      end

      def set_user
        @user = User.select(:id, :username).find_by(id: params[:user_id])
        json_response(:not_found, "User not found") unless @user
      end

      def json_response(status, message, data = nil)
        response_status = case status
        when :ok then "success"
        when :accepted then "processing"
        else "error"
        end

        render json: {
          status: response_status,
          message: message,
          data: data
        }, status: status
      end
    end
  end
end
