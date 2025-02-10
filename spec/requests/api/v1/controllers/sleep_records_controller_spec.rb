require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :request do
  let(:user) { create(:user) }
  let!(:sleep_records) { create_list(:sleep_record, 5, user: user) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe "GET /api/v1/users/:user_id/sleep_records" do
    before { get "/api/v1/users/#{user.id}/sleep_records" }

    it "returns a list of sleep records without N+1 queries" do
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["message"]).to eq("Sleep records retrieved successfully")
      expect(json["data"]).to be_a(Hash)
      expect(json["data"]["user"]["id"]).to eq(user.id)
      expect(json["data"]["user"]["username"]).to eq(user.username)
      expect(json["data"]["sleep_records"]).to be_an(Array)
      expect(json["data"]["sleep_records"].size).to eq(5)
    end
  end

  describe "POST /api/v1/users/:user_id/sleep_records/start_sleep" do
    it "enqueues a background job to start sleep" do
      expect {
        post "/api/v1/users/#{user.id}/sleep_records/start_sleep"
      }.to have_enqueued_job(SleepRecordJob).with(user.id, :start_sleep).exactly(:once)

      expect(response).to have_http_status(:accepted)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("processing")
      expect(json["message"]).to eq("Clock-in request received and processing in background.")
    end
  end

  describe "PATCH /api/v1/users/:user_id/sleep_records/stop_sleep" do
    before { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }

    it "enqueues a background job to stop sleep" do
      expect {
        patch "/api/v1/users/#{user.id}/sleep_records/stop_sleep"
      }.to have_enqueued_job(SleepRecordJob).with(user.id, :stop_sleep).exactly(:once)

      expect(response).to have_http_status(:accepted)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("processing")
      expect(json["message"]).to eq("Clock-out request received and processing in background.")
    end
  end
end
