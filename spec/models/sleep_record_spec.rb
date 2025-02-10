require 'rails_helper'

class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validate :clock_out_after_clock_in, if: -> { clock_out.present? }

  before_save :calculate_duration

  private

  def clock_out_after_clock_in
    if clock_out && clock_out <= clock_in
      errors.add(:clock_out, "must be after clock in")
    end
  end

  def calculate_duration
    return unless clock_out

    self.duration = clock_out - clock_in # Duration in seconds
  end
end
