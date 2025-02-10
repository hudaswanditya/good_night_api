require 'rails_helper'

RSpec.describe SleepRecordJob, type: :job do
  let(:user) { create(:user) }
  let(:service) { instance_double(SleepRecordsService) }

  before do
    allow(SleepRecordsService).to receive(:new).with(user).and_return(service)
  end

  describe "#perform" do
    context "when the job is for start_sleep" do
      it "calls start_sleep on the service" do
        expect(service).to receive(:start_sleep)

        SleepRecordJob.perform_now(user.id, :start_sleep)
      end
    end

    context "when the job is for stop_sleep" do
      it "calls stop_sleep on the service" do
        expect(service).to receive(:stop_sleep)

        SleepRecordJob.perform_now(user.id, :stop_sleep)
      end
    end

    context "when an invalid action is provided" do
      it "raises an error" do
        expect {
          SleepRecordJob.perform_now(user.id, :invalid_action)
        }.to raise_error(ArgumentError, "Invalid action for SleepRecordJob: invalid_action")
      end
    end
  end
end
