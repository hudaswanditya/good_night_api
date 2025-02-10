class SleepRecordsController < ApplicationController
  before_action :set_user

  def index
    records = @user.sleep_records.includes(:user).order(created_at: :desc)

    if records.any?
      render json: { user: @user, sleep_records: records }
    else
      render json: { message: "No sleep records found." }, status: :ok
    end
  end

  # POST /users/:user_id/sleep_records/start
  def start_sleep
    result = SleepRecordsService.new(@user).start_sleep
    render json: result.except(:status), status: result[:status]
  end

  # PATCH /users/:user_id/sleep_records/stop
  def stop_sleep
    result = SleepRecordsService.new(@user).stop_sleep
    render json: result.except(:status), status: result[:status]
  end

  private

  def set_user
    @user = User.select(:id, :username).find(params[:user_id])
  end
end
