require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'Retrieves a paginated list of users' do
      tags 'Users'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, description: 'Page number (default: 1)'

      response '200', 'Users retrieved successfully' do
        let(:page) { 1 }

        before do
          create_list(:user, 10)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].size).to eq(10)
        end
      end
    end
  end

  path '/api/v1/users/{id}' do
    get 'Retrieves a specific user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      response '200', 'User retrieved successfully' do
        let!(:user) { create(:user) }
        let(:id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(user.id)
        end
      end

      response '404', 'User not found' do
        let(:id) { 9999 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to eq("User not found")
        end
      end
    end
  end

  path '/api/v1/users/{id}/following_sleep_records' do
    get 'Retrieves sleep records of followed users from the last week' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      response '200', 'Following sleep records retrieved successfully' do
        let!(:user) { create(:user) }
        let!(:followed_user) { create(:user) }
        let(:id) { user.id }

        before do
          user.followed_users << followed_user
          create_list(:sleep_record, 2, user: followed_user, clock_in: 2.days.ago, clock_out: 1.day.ago)
          user.reload
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].size).to eq(2)
        end
      end

      response '404', 'User not found' do
        let(:id) { 9999 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to eq("User not found")
        end
      end
    end
  end
end
