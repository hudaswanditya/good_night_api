class RelationshipJob
  include Sidekiq::Worker

  def perform(user_id, target_user_id, action)
    user = User.find(user_id)
    target_user = User.find(target_user_id)

    case action.to_sym
    when :follow
      user.follow(target_user)
    when :unfollow
      user.unfollow(target_user)
    else
      Rails.logger.error "Unknown action: #{action}"
    end
  end
end
