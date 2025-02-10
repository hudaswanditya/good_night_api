class SleepRecordsService
  def initialize(user)
    @user = user
  end

  def stop_sleep
    last_record = @user.sleep_records.order(clock_in: :desc).limit(1).take

    if last_record.nil? || last_record.clock_in.nil?
      return { error: "No active sleep session to stop.", status: :unprocessable_entity }
    elsif last_record.clock_out.present?
      return { error: "Already clocked out. Start a new session first.", status: :unprocessable_entity }
    end

    SleepRecordJob.perform_later(@user.id, :stop_sleep)

    { message: "Clock-out request received and processing in background.", status: :accepted }
  end


  def start_sleep
    last_record = @user.sleep_records.order(clock_in: :desc).limit(1).take

    if last_record.nil?
      return enqueue_start_sleep
    end

    if last_record.clock_out.nil?
      return { error: "Already clocked in. Please stop sleep before starting again.", status: :unprocessable_entity }
    end

    enqueue_start_sleep
  end

  private

  def enqueue_start_sleep
    SleepRecordJob.perform_later(@user.id, :start_sleep)
    { message: "Clock-in request received and processing in background.", status: :accepted }
  end
end
