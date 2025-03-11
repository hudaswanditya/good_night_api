class SleepRecordJob < ApplicationJob
  queue_as :default

  def perform(user_id, action)
    redis = Redis.new
    redis_key = "user:#{user_id}:sleep_action"
    redis_ttl = 5

    return if redis.get(redis_key)

    redis.setex(redis_key, redis_ttl, "locked")
    user = User.find_by(id: user_id)
    return unless user

    service = SleepRecordsService.new(user)
    case action
    when :start_sleep then service.start_sleep
    when :stop_sleep then service.stop_sleep
    else raise ArgumentError, "Invalid action for SleepRecordJob: invalid_action"
    end
  ensure
    redis.del(redis_key)
  end
end
