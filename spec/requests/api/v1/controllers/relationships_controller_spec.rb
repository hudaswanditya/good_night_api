require 'rails_helper'

RSpec.describe Api::V1::RelationshipsController, type: :request do
  let(:user) { create(:user) }
  let(:target_user) { create(:user) }

  describe "POST /api/v1/users/:id/follow/:target_user_id" do
    context "when following another user" do
      it "allows a user to follow another user" do
        post "/api/v1/users/#{user.id}/follow/#{target_user.id}"

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(json_response[:status]).to eq("success")
        expect(json_response[:message]).to eq("User followed successfully")
        expect(user.following?(target_user)).to be true
      end

      it "prevents a user from following themselves" do
        post "/api/v1/users/#{user.id}/follow/#{user.id}"

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:message]).to eq("Cannot follow yourself")
      end
    end

    context "when trying to follow a non-existent user" do
      it "returns a 404 error" do
        post "/api/v1/users/#{user.id}/follow/9999"

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:message]).to eq("User not found")
      end
    end
  end

  describe "DELETE /api/v1/users/:id/unfollow/:target_user_id" do
    before { user.follow(target_user) }

    it "allows a user to unfollow another user" do
      delete "/api/v1/users/#{user.id}/unfollow/#{target_user.id}"

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("User unfollowed successfully")
      expect(user.following?(target_user)).to be false
    end

    it "returns success even if the user is not following the target" do
      delete "/api/v1/users/#{user.id}/unfollow/#{target_user.id}"

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("User unfollowed successfully")
    end
  end

  describe "GET /api/v1/users/:id/followers" do
    before { target_user.follow(user) }

    it "returns the followers list with structured response" do
      get "/api/v1/users/#{user.id}/followers"

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("Followers retrieved successfully")
      expect(json_response[:data]).to be_an(Array)
      expect(json_response[:data].first[:id]).to eq(target_user.id)
      expect(json_response[:data].first[:username]).to eq(target_user.username)
    end
  end

  describe "GET /api/v1/users/:id/following" do
    before { user.follow(target_user) }

    it "returns the following list with structured response" do
      get "/api/v1/users/#{user.id}/following"

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("Following list retrieved successfully")
      expect(json_response[:data]).to be_an(Array)
      expect(json_response[:data].first[:id]).to eq(target_user.id)
      expect(json_response[:data].first[:username]).to eq(target_user.username)
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

    it "returns sleep records of followed users sorted by sleep duration" do
      get "/api/v1/users/#{user.id}/following_sleep_records"

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("Following sleep records retrieved successfully")
      expect(json_response[:data].length).to eq(2)
      expect(json_response[:data].first[:user_id]).to eq(friend2.id) # Longer sleep first
      expect(json_response[:data].last[:user_id]).to eq(friend1.id) # Shorter sleep last
    end

    it "returns an empty array if no sleep records exist for followed users" do
      SleepRecord.delete_all

      get "/api/v1/users/#{user.id}/following_sleep_records"

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("Following sleep records retrieved successfully")
      expect(json_response[:data]).to eq([])
    end
  end
end
