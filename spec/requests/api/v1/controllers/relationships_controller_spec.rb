require 'rails_helper'

RSpec.describe Api::V1::RelationshipsController, type: :request do
  let(:user) { create(:user) }
  let(:target_user) { create(:user) }

  describe "POST /api/v1/users/:id/follow/:target_user_id" do
    context "when following another user" do
      it "allows a user to follow another user" do
        post "/api/v1/users/#{user.id}/follow/#{target_user.id}"

        expect(response).to have_http_status(:ok)
        expect(user.following?(target_user)).to be true
      end

      it "prevents a user from following themselves" do
        post "/api/v1/users/#{user.id}/follow/#{user.id}"

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Cannot follow yourself")
      end
    end

    context "when trying to follow a non-existent user" do
      it "returns a 404 error" do
        post "/api/v1/users/#{user.id}/follow/9999" # Assuming ID 9999 doesn't exist

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/v1/users/:id/unfollow/:target_user_id" do
    before { user.follow(target_user) }

    it "allows a user to unfollow another user" do
      delete "/api/v1/users/#{user.id}/unfollow/#{target_user.id}"

      expect(response).to have_http_status(:ok)
      expect(user.following?(target_user)).to be false
    end

    it "does nothing if the user is not following the target" do
      delete "/api/v1/users/#{user.id}/unfollow/#{target_user.id}"

      expect(response).to have_http_status(:ok) # Should return OK even if nothing changes
    end
  end

  describe "GET /api/v1/users/:id/followers" do
    before { target_user.follow(user) } # target_user is a follower of user

    it "returns the followers list with limited attributes" do
      get "/api/v1/users/#{user.id}/followers"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to be_an(Array)
      expect(json.first["id"]).to eq(target_user.id)
      expect(json.first["username"]).to eq(target_user.username)
    end
  end

  describe "GET /api/v1/users/:id/following" do
    before { user.follow(target_user) } # user is following target_user

    it "returns the following list with limited attributes" do
      get "/api/v1/users/#{user.id}/following"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to be_an(Array)
      expect(json.first["id"]).to eq(target_user.id)
      expect(json.first["username"]).to eq(target_user.username)
    end
  end

  describe "GET /api/v1/users/:id/following_sleep_records" do
    let(:friend1) { create(:user) }
    let(:friend2) { create(:user) }

    before do
      create(:relationship, follower: user, following: friend1)
      create(:relationship, follower: user, following: friend2)

      create(:sleep_record, user: friend1, clock_in: 1.week.ago.beginning_of_week, clock_out: 1.week.ago.beginning_of_week + 6.hours)
      create(:sleep_record, user: friend2, clock_in: 1.week.ago.beginning_of_week, clock_out: 1.week.ago.beginning_of_week + 8.hours)
    end

    it "returns sleep records of all following users from the last week, sorted by sleep duration" do
      get "/api/v1/users/#{user.id}/following_sleep_records"

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(2)
      expect(json_response.first["user_id"]).to eq(friend2.id) # Friend with longer sleep duration should come first
      expect(json_response.last["user_id"]).to eq(friend1.id) # Friend with shorter sleep duration should come last
    end

    it "returns an empty array if no friends have sleep records from last week" do
      SleepRecord.delete_all

      get "/api/v1/users/#{user.id}/following_sleep_records"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end
end
