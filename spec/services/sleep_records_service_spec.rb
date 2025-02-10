require 'rails_helper'

RSpec.describe SleepRecordsService do
  let(:user) { create(:user) }
  let(:service) { SleepRecordsService.new(user) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "#start_sleep" do
    context "when no sleep record exists" do
      it "enqueues a background job to start sleep" do
        expect {
          service.start_sleep
        }.to have_enqueued_job(SleepRecordJob).with(user.id, :start_sleep)
      end
    end

    context "when a previous session exists but is completed" do
      before do
        create(:sleep_record, user: user, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
      end

      it "enqueues a background job to start sleep" do
        expect {
          service.start_sleep
        }.to have_enqueued_job(SleepRecordJob).with(user.id, :start_sleep)
      end
    end

    context "when an active session exists (no clock_out)" do
      before do
        create(:sleep_record, user: user, clock_in: Time.current, clock_out: nil)
      end

      it "does not allow starting a new session" do
        result = service.start_sleep

        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:error]).to eq("Already clocked in. Please stop sleep before starting again.")
      end
    end
  end

  describe "#stop_sleep" do
    context "when an active sleep session exists" do
      let!(:record) { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }

      it "enqueues a background job to stop sleep" do
        expect {
          service.stop_sleep
        }.to have_enqueued_job(SleepRecordJob).with(user.id, :stop_sleep)
      end
    end

    context "when no active sleep session exists" do
      it "returns an error without enqueuing a job" do
        result = service.stop_sleep

        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:error]).to eq("No active sleep session to stop.")
      end
    end

    context "when the last session is already completed" do
      before do
        create(:sleep_record, user: user, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
      end

      it "does not enqueue a job when stopping a completed session" do
        result = service.stop_sleep

        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:error]).to eq("Already clocked out. Start a new session first.")
      end
    end
  end
end
