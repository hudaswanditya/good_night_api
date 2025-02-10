class User < ApplicationRecord
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :following

  has_many :reverse_relationships, class_name: "Relationship", foreign_key: "following_id", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  has_many :sleep_records

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def follow(user)
    return if self == user || following?(user)

    relationships.create!(following_id: user.id)
  end

  def unfollow(user)
    relationships.where(following_id: user.id).delete_all
  end

  def following?(user)
    followed_users.loaded? ? followed_users.include?(user) : relationships.exists?(following_id: user.id)
  end

  def follower?(user)
    followers.loaded? ? followers.include?(user) : reverse_relationships.exists?(follower_id: user.id)
  end
end
