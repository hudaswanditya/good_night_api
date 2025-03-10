class BatchUserLookupJob < ApplicationJob
  queue_as :low_priority

  def perform(user_ids)
    users = User.where(id: user_ids).select(:id, :username, :created_at)
    users.each do |user|
      Rails.cache.write("user_#{user.id}", user, expires_in: 10.minutes)
    end
  end
end
