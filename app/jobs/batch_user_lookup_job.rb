class BatchUserLookupJob
  include Sidekiq::Worker

  def perform(user_ids)
    users = User.where(id: user_ids).select(:id, :username, :created_at)

    users.each do |user|
      Rails.cache.write("user_#{user.id}", user, expires_in: 60.minutes)
    end
  end
end
