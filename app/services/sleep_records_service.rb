class SleepRecordsService
  def initialize(user)
    @user = user
  end

  def stop_sleep
    last_record = @user.sleep_records.order(clock_in: :desc).limit(1).take

    if last_record.nil? || last_record.clock_in.nil?
      return { error: "No active sleep session to stop.", status: :unprocessable_entity }
    elsif last_record.clock_out.present?
      return { error: "No active sleep session to stop. Start a new session first.", status: :unprocessable_entity }
    end

    last_record.update(clock_out: Time.current)
    { message: "Clocked out", record: last_record, status: :ok }
  end

  def start_sleep
    last_record = @user.sleep_records.order(clock_in: :desc).limit(1).take

    # If no sleep record exists, create a new one
    if last_record.nil?
      return create_new_sleep_record
    end

    # If the last record has no clock_out, prevent starting a new session
    if last_record.clock_out.nil?
      return { error: "Already clocked in. Please stop sleep before starting again.", status: :unprocessable_entity }
    end

    # Otherwise, create a new sleep session
    create_new_sleep_record
  end

  private

  def create_new_sleep_record
    new_record = @user.sleep_records.create(clock_in: Time.current)

    if new_record.persisted?
      { message: "Clocked in", record: new_record, status: :created }
    else
      { error: "Failed to start sleep session.", status: :unprocessable_entity }
    end
  end
end
