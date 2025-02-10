module Api
  module V1
    class RelationshipsController < ApplicationController
      before_action :set_users, only: [ :follow, :unfollow ]
      before_action :set_user_with_associations, only: [ :followers, :following ]

      def follow
        if @user == @target_user
          return json_response(:unprocessable_entity, "Cannot follow yourself")
        end

        @user.follow(@target_user)
        json_response(:ok, "User followed successfully")
      end

      def unfollow
        @user.unfollow(@target_user)
        json_response(:ok, "User unfollowed successfully")
      end

      def followers
        followers = @user.followers.select(:id, :username).limit(50)
        json_response(:ok, "Followers retrieved successfully", followers)
      end

      def following
        following = @user.followed_users.select(:id, :username).limit(50)
        json_response(:ok, "Following list retrieved successfully", following)
      end

      private

      def set_users
        @user, @target_user = User.where(id: [ params[:id], params[:target_user_id] ])
                                  .index_by(&:id)
                                  .values_at(params[:id].to_i, params[:target_user_id].to_i)

        return if @user && @target_user

        json_response(:not_found, "User not found")
      end

      def set_user_with_associations
        @user = User.includes(:followers, :followed_users).find_by(id: params[:id])
        json_response(:not_found, "User not found") unless @user
      end

      def json_response(status, message, data = nil)
        render json: {
          status: status == :ok ? "success" : "error",
          message: message,
          data: data
        }, status: status
      end
    end
  end
end
