require 'rails_helper'

RSpec.describe "API::V1::Relationships", type: :request do
  let!(:user) { create(:user) }
  let!(:target_user) { create(:user) }

  def json
    JSON.parse(response.body)
  end

  describe "POST /api/v1/users/:id/follow/:target_user_id" do
    context "when following a user" do
      it "returns success response" do
        post "/api/v1/users/#{user.id}/follow/#{target_user.id}"

        expect(response).to have_http_status(:ok)
        expect(json['status']).to eq('success')
        expect(json['message']).to eq('User followed successfully')
      end
    end
  end

  describe "DELETE /api/v1/users/:id/unfollow/:target_user_id" do
    before do
      user.follow(target_user)
    end

    context "when unfollowing a user" do
      it "returns success response" do
        delete "/api/v1/users/#{user.id}/unfollow/#{target_user.id}"

        expect(response).to have_http_status(:ok)
        expect(json['status']).to eq('success')
        expect(json['message']).to eq('User unfollowed successfully')
      end
    end
  end

  describe "GET /api/v1/users/:id/followers" do
    before do
      target_user.follow(user)
    end

    it "retrieves followers list" do
      get "/api/v1/users/#{user.id}/followers"

      expect(response).to have_http_status(:ok)
      expect(json['status']).to eq('success')
      expect(json['message']).to eq('Followers retrieved successfully')
      expect(json['data']).to be_an(Array)
      expect(json['data'].first['id']).to eq(target_user.id)
    end
  end

  describe "GET /api/v1/users/:id/following" do
    before do
      user.follow(target_user)
    end

    it "retrieves following list" do
      get "/api/v1/users/#{user.id}/following"

      expect(response).to have_http_status(:ok)
      expect(json['status']).to eq('success')
      expect(json['message']).to eq('Following list retrieved successfully')
      expect(json['data']).to be_an(Array)
      expect(json['data'].first['id']).to eq(target_user.id)
    end
  end
end
