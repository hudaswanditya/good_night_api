class SleepRecordsService
  def initialize(user)
    @user = user
    @redis_key = "user:#{@user.id}:active_sleep"
    @redis = Redis.new # Establish Redis connection
  end

  def start_sleep
    return { status: :conflict, message: "Already clocked in. Please stop sleep before starting again." } if active_sleep_session?

    @redis.set(@redis_key, "locked", ex: 3600)
    SleepRecordJob.perform_later(@user.id, :start_sleep)
    { status: :accepted, message: "Sleep session started." }
  end

  def stop_sleep
    last_sleep_record = @user.sleep_records.where(clock_out: nil).order(created_at: :desc).first
    return { status: :unprocessable_entity, message: "No active sleep session to stop." } unless last_sleep_record

    SleepRecordJob.perform_later(@user.id, :stop_sleep)
    @redis.del(@redis_key)
    { status: :accepted, message: "Sleep session stopped." }
  end

  private

  def active_sleep_session?
    @redis.exists?(@redis_key) || @user.sleep_records.exists?(clock_out: nil)
  end
end
