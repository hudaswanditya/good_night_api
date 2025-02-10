module Api
  module V1
    class RelationshipsController < ApplicationController
      before_action :set_users, only: [ :follow, :unfollow ]
      before_action :set_user_with_associations, only: [ :followers, :following ]

      def follow
        return render json: { error: "Cannot follow yourself" }, status: :unprocessable_entity if @user == @target_user

        @user.follow(@target_user)
        head :ok
      end

      def unfollow
        @user.unfollow(@target_user)
        head :ok
      end

      def followers
        followers = @user.followers.select(:id, :username).limit(50)
        render json: format_users(followers)
      end

      def following
        following = @user.followed_users.select(:id, :username).limit(50)
        render json: format_users(following)
      end

      private

      def set_users
        @user, @target_user = User.where(id: [ params[:id], params[:target_user_id] ])
                                  .index_by(&:id)
                                  .values_at(params[:id].to_i, params[:target_user_id].to_i)
        render json: { error: "User not found" }, status: :not_found if @user.nil? || @target_user.nil?
      end

      def set_user_with_associations
        @user = User.includes(:followers, :followed_users).find_by(id: params[:id])
        render json: { error: "User not found" }, status: :not_found unless @user
      end

      def format_users(users)
        users.map { |user| { id: user.id, username: user.username } }
      end
    end
  end
end
