class UsersController < ApplicationController
  before_action :set_user, only: [ :show ]

  def index
    users = User.all
    render json: users
  end

  def show
    render json: @user
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    render json: { error: "User not found" }, status: :not_found unless @user
  end
end
