class User < ApplicationRecord
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :following

  has_many :reverse_relationships, class_name: "Relationship", foreign_key: "following_id", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  has_many :sleep_records

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def follow(user)
    return if self == user || following?(user)

    relationships.find_or_create_by(following_id: user.id)
  end

  def unfollow(user)
    relationships.where(following_id: user.id).delete_all
  end

  def following?(user)
    relationships.exists?(following_id: user.id)
  end

  def follower?(user)
    reverse_relationships.exists?(follower_id: user.id)
  end

  def following_sleep_records_last_week
    start_time = 1.week.ago.beginning_of_week
    end_time = 1.week.ago.end_of_week

    SleepRecord
      .joins(:user)
      .where(users: { id: followed_users.pluck(:id) })
      .where(clock_in: start_time..end_time)
      .select("sleep_records.*, (EXTRACT(EPOCH FROM (clock_out - clock_in)) / 3600) AS sleep_duration")
      .order("sleep_duration DESC")
  end

  def cached_followed_users
    Rails.cache.fetch("user_#{id}_followed_users", expires_in: 10.minutes) do
      followed_users.select(:id, :username).to_a
    end
  end

  def cached_followers
    Rails.cache.fetch("user_#{id}_followers", expires_in: 10.minutes) do
      followers.select(:id, :username).to_a
    end
  end
end
