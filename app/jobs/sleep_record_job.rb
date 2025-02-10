class SleepRecordJob < ApplicationJob
  queue_as :default

  def perform(user_id, action)
    user = User.find_by(id: user_id)
    return unless user

    service = SleepRecordsService.new(user)

    case action
    when :start_sleep
      service.start_sleep
    when :stop_sleep
      service.stop_sleep
    else
      raise ArgumentError, "Invalid action for SleepRecordJob: #{action}"
    end
  end
end
