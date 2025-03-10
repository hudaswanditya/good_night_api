class RefreshUsersCacheJob
  include Sidekiq::Worker

  def perform
    (1..total_pages).each do |page|
      cache_key = "users_list_page_#{page}"
      users = User.select(:id, :username, :created_at).order(created_at: :desc).offset((page - 1) * 50).limit(50)
      Rails.cache.write(cache_key, users, expires_in: 60.minutes)
    end
  end

  private

  def total_pages
    (User.count / 50.0).ceil
  end
end
