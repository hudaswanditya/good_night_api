require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:users) { create_list(:user, 3) }
  let(:user_id) { users.first.id }

  describe "GET /users" do
    before { get "/api/v1/users" }

    it "returns all users" do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "GET /users/:id" do
    context "when the user exists" do
      before { get "/api/v1/users/#{user_id}" }

      it "returns the user" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["id"]).to eq(user_id)
      end
    end

    context "when the user does not exist" do
      before { get "/users/999999" }

      it "returns a 404 not found" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
