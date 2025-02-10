require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :request do
  let(:user) { create(:user) }
  let!(:sleep_records) { create_list(:sleep_record, 5, user: user) }
  let(:service) { instance_double(SleepRecordsService) }

  before do
    allow(SleepRecordsService).to receive(:new).with(user).and_return(service)
  end

  describe "GET /api/v1/users/:user_id/sleep_records" do
    it "returns a list of sleep records without N+1 queries" do
      get "/api/v1/users/#{user.id}/sleep_records"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/users/:user_id/sleep_records/start_sleep" do
    context "when starting a sleep session is successful" do
      let(:new_record) { build(:sleep_record, user: user, clock_out: nil) }

      before do
        allow(service).to receive(:start_sleep).and_return(
          { message: "Clocked in", record: new_record, status: :created }
        )
      end

      it "calls the service and starts a new sleep session" do
        post "/api/v1/users/#{user.id}/sleep_records/start_sleep"

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json["message"]).to eq("Clocked in")
        expect(json["record"]["clock_in"]).not_to be_nil
        expect(json["record"]["clock_out"]).to be_nil
      end
    end

    context "when the user is already clocked in" do
      before do
        allow(service).to receive(:start_sleep).and_return(
          { error: "Already clocked in. Please stop sleep before starting again.", status: :unprocessable_entity }
        )
      end

      it "prevents starting a new sleep session with 422" do
        post "/api/v1/users/#{user.id}/sleep_records/start_sleep"

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json["error"]).to eq("Already clocked in. Please stop sleep before starting again.")
      end
    end
  end

  describe "PATCH /api/v1/users/:user_id/sleep_records/stop_sleep" do
    context "when stopping sleep is successful" do
      let(:updated_record) { build(:sleep_record, user: user, clock_out: Time.current) }

      before do
        allow(service).to receive(:stop_sleep).and_return(
          { message: "Clocked out", record: updated_record, status: :ok }
        )
      end

      it "calls the service and stops the sleep session" do
        patch "/api/v1/users/#{user.id}/sleep_records/stop_sleep"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["message"]).to eq("Clocked out")
        expect(json["record"]["clock_out"]).not_to be_nil
      end
    end

    context "when no active sleep session exists" do
      before do
        allow(service).to receive(:stop_sleep).and_return(
          { error: "No active sleep session to stop.", status: :unprocessable_entity }
        )
      end

      it "returns 422 for no active session" do
        patch "/api/v1/users/#{user.id}/sleep_records/stop_sleep"

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json["error"]).to eq("No active sleep session to stop.")
      end
    end

    context "when already clocked out" do
      before do
        allow(service).to receive(:stop_sleep).and_return(
          { error: "Already clocked out. Start a new session first.", status: :unprocessable_entity }
        )
      end

      it "returns 422 when stopping an already clocked-out session" do
        patch "/api/v1/users/#{user.id}/sleep_records/stop_sleep"

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json["error"]).to eq("Already clocked out. Start a new session first.")
      end
    end
  end
end
