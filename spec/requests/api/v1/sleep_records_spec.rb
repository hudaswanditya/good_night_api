require 'swagger_helper'

RSpec.describe 'Sleep Records API', type: :request do
  path '/api/v1/users/{user_id}/sleep_records' do
    get 'Retrieves a list of sleep records' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :integer, description: 'User ID'

      response '200', 'Sleep records retrieved successfully' do
        let(:user) { create(:user) }
        let!(:sleep_records) { create_list(:sleep_record, 3, user: user) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['sleep_records'].size).to eq(3)
        end
      end

      response '404', 'User not found' do
        let(:user_id) { 9999 }
        run_test!
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/start_sleep' do
    post 'Starts a sleep session' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :integer, description: 'User ID'

      response '202', 'Clock-in request received and processing in background' do
        let(:user) { create(:user) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('processing')
        end
      end

      response '404', 'User not found' do
        let(:user_id) { 9999 }
        run_test!
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/stop_sleep' do
    patch 'Stops a sleep session' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :integer, description: 'User ID'

      response '202', 'Clock-out request received and processing in background' do
        let(:user) { create(:user) }
        let!(:sleep_record) { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }
        let(:user_id) { user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('processing')
        end
      end

      response '404', 'User not found' do
        let(:user_id) { 9999 }
        run_test!
      end
    end
  end
end
