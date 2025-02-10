require 'rails_helper'

RSpec.describe SleepRecordsService do
  let(:user) { create(:user) }
  let(:service) { SleepRecordsService.new(user) }

  describe "#start_sleep" do
    context "when no sleep record exists" do
      it "creates a new sleep record" do
        result = service.start_sleep

        expect(result[:status]).to eq(:created)
        expect(result[:message]).to eq("Clocked in")
        expect(result[:record]).to be_persisted
        expect(result[:record].clock_in).not_to be_nil
        expect(result[:record].clock_out).to be_nil
      end
    end

    context "when a previous session exists but is completed" do
      before do
        create(:sleep_record, user: user, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
      end

      it "creates a new sleep record" do
        result = service.start_sleep

        expect(result[:status]).to eq(:created)
        expect(result[:message]).to eq("Clocked in")
        expect(result[:record]).to be_persisted
        expect(result[:record].clock_in).not_to be_nil
        expect(result[:record].clock_out).to be_nil
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

      it "stops the active session" do
        result = service.stop_sleep

        expect(result[:status]).to eq(:ok)
        expect(result[:message]).to eq("Clocked out")
        expect(result[:record].clock_out).not_to be_nil
        expect(result[:record].clock_out).to be_within(1.second).of(Time.current)
      end
    end

    context "when no active sleep session exists" do
      it "returns an error" do
        result = service.stop_sleep

        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:error]).to eq("No active sleep session to stop.")
      end
    end

    context "when the last session is already completed" do
      before do
        create(:sleep_record, user: user, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
      end

      it "does not allow stopping a completed session" do
        result = service.stop_sleep

        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:error]).to eq("No active sleep session to stop. Start a new session first.")
      end
    end
  end
end
