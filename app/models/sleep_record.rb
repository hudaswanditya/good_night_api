class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validate :clock_out_after_clock_in, if: -> { clock_out.present? }

  before_save :calculate_duration, if: -> { will_save_change_to_clock_out? || will_save_change_to_clock_in? }

  private

  def clock_out_after_clock_in
    errors.add(:clock_out, "must be after clock in") if clock_out && clock_out <= clock_in
  end

  def calculate_duration
    self.duration = clock_out - clock_in if clock_out
  end

  def self.cached_last_week_sleep_records(user_id)
    Rails.cache.fetch("user_#{user_id}_sleep_records_last_week", expires_in: 1.hour) do
      where(user_id: user_id)
        .where("clock_in >= ?", 1.week.ago)
        .order(clock_in: :desc)
        .select(:id, :clock_in, :clock_out, :duration)
    end
  end
end
