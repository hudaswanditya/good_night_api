module Api
  module V1
    class RelationshipsController < ApplicationController
      before_action :set_users, only: %i[follow unfollow]
      before_action :set_user, only: %i[followers following]

      def follow
        return json_response(:unprocessable_entity, "Cannot follow yourself") if @user == @target_user
        return json_response(:unprocessable_entity, "Already following this user") if @user.following?(@target_user)

        RelationshipJob.perform_async(@user.id, @target_user.id, "follow")
        json_response(:accepted, "Follow request is being processed")
      end

      def unfollow
        return json_response(:unprocessable_entity, "Not following this user") unless @user.following?(@target_user)

        RelationshipJob.perform_async(@user.id, @target_user.id, "unfollow")
        json_response(:accepted, "Unfollow request is being processed")
      end

      def followers
        followers = @user.followers.pluck(:id, :username).map { |id, username| { id:, username: } }
        json_response(:ok, "Followers retrieved successfully", followers)
      end

      def following
        following = @user.followed_users.pluck(:id, :username).map { |id, username| { id:, username: } }
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

      def set_user
        @user = User.find_by(id: params[:id])
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
