class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validate :clock_out_after_clock_in, if: :clock_out?

  after_save :calculate_duration, if: -> { saved_change_to_clock_out? }

  scope :last_week, ->(user_id) { where(user_id: user_id).where("clock_in >= ?", 1.week.ago) }

  def self.cached_last_week_sleep_records(user_id)
    Rails.cache.fetch("user_#{user_id}_sleep_records_last_week", expires_in: 1.hour) do
      last_week(user_id).order(clock_in: :desc)
                        .pluck(:id, :clock_in, :clock_out, :duration)
                        .map { |id, clock_in, clock_out, duration| { id:, clock_in:, clock_out:, duration: } }
    end
  end

  private

  def clock_out_after_clock_in
    errors.add(:clock_out, "must be after clock in") if clock_out <= clock_in
  end

  def calculate_duration
    update_column(:duration, clock_out - clock_in) if clock_out && clock_in
  end
end
