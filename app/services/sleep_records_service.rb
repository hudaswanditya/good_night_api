class SleepRecordsService
  def initialize(user)
    @user = user
  end

  def stop_sleep
    last_record = @user.sleep_records.where(clock_out: nil).order(clock_in: :desc).lock("FOR UPDATE").limit(1).take

    if last_record.nil?
      return { error: "Already clocked out. Start a new session first.", status: :unprocessable_entity }
    end

    if last_record.clock_out.present?
      return { error: "Already clocked out. Start a new session first.", status: :unprocessable_entity }
    end

    unless Rails.cache.read("sleep_job_#{@user.id}_stop")
      Rails.cache.write("sleep_job_#{@user.id}_stop", true, expires_in: 5.seconds)
      SleepRecordJob.set(wait: 1.second).perform_later(@user.id, :stop_sleep)
    end

    { message: "Clock-out request received and processing in background.", status: :accepted }
  end

  def start_sleep
    last_record = @user.sleep_records.where(clock_out: nil).order(clock_in: :desc).lock("FOR UPDATE").limit(1).take

    if last_record
      return { error: "Already clocked in. Please stop sleep before starting again.", status: :unprocessable_entity }
    end

    unless Rails.cache.read("sleep_job_#{@user.id}_start")
      Rails.cache.write("sleep_job_#{@user.id}_start", true, expires_in: 5.seconds)
      SleepRecordJob.set(wait: 1.second).perform_later(@user.id, :start_sleep)
    end

    { message: "Clock-in request received and processing in background.", status: :accepted }
  end
end
