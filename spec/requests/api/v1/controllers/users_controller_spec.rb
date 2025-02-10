require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:users) { create_list(:user, 3) }
  let(:user_id) { users.first.id }

  describe "GET /api/v1/users" do
    before { get "/api/v1/users" }

    it "returns all users with structured response" do
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("success")
      expect(json_response[:message]).to eq("Users retrieved successfully")
      expect(json_response[:data].size).to eq(3)
    end
  end

  describe "GET /api/v1/users/:id" do
    context "when the user exists" do
      before { get "/api/v1/users/#{user_id}" }

      it "returns the user with structured response" do
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(json_response[:status]).to eq("success")
        expect(json_response[:message]).to eq("User retrieved successfully")
        expect(json_response[:data][:id]).to eq(user_id)
      end
    end

    context "when the user does not exist" do
      before { get "/api/v1/users/999999" }

      it "returns a 404 not found with structured response" do
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:message]).to eq("User not found")
        expect(json_response[:errors]).to include("The requested user does not exist")
      end
    end
  end
end
