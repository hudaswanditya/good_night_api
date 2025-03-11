require 'swagger_helper'

RSpec.describe 'Relationships API', type: :request do
  path '/api/v1/users/{id}/follow/{target_user_id}' do
    post 'Follow a user' do
      tags 'Relationships'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'
      parameter name: :target_user_id, in: :path, type: :integer, description: 'Target User ID'

      response '202', 'User followed successfully' do
        let(:user) { create(:user) }
        let(:target_user) { create(:user) }
        let(:id) { user.id }
        let(:target_user_id) { target_user.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('processing')
          expect(json['message']).to eq('Follow request is being processed')
        end
      end

      response '404', 'User not found' do
        let(:id) { 9999 }
        let(:target_user_id) { 8888 }
        run_test!
      end

      response '422', 'Cannot follow yourself' do
        let(:user) { create(:user) }
        let(:id) { user.id }
        let(:target_user_id) { user.id }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/unfollow/{target_user_id}' do
    delete 'Unfollow a user' do
      tags 'Relationships'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'
      parameter name: :target_user_id, in: :path, type: :integer, description: 'Target User ID'

      response '202', 'User unfollowed successfully' do
        let(:user) { create(:user) }
        let(:target_user) { create(:user) }
        let(:id) { user.id }
        let(:target_user_id) { target_user.id }

        before { user.follow(target_user) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('processing')
          expect(json['message']).to eq('Unfollow request is being processed')
        end
      end

      response '404', 'User not found' do
        let(:id) { 9999 }
        let(:target_user_id) { 8888 }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/followers' do
    get 'Retrieves followers of a user' do
      tags 'Relationships'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      response '200', 'Followers retrieved successfully' do
        let(:user) { create(:user) }
        let(:follower) { create(:user) }
        let(:id) { user.id }

        before { follower.follow(user) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('success')
          expect(json['message']).to eq('Followers retrieved successfully')
          expect(json['data'].size).to eq(1)
          expect(json['data'].first['id']).to eq(follower.id)
        end
      end

      response '404', 'User not found' do
        let(:id) { 9999 }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/following' do
    get 'Retrieves following list of a user' do
      tags 'Relationships'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      response '200', 'Following list retrieved successfully' do
        let(:user) { create(:user) }
        let(:following_user) { create(:user) }
        let(:id) { user.id }

        before { user.follow(following_user) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('success')
          expect(json['message']).to eq('Following list retrieved successfully')
          expect(json['data'].size).to eq(1)
          expect(json['data'].first['id']).to eq(following_user.id)
        end
      end

      response '404', 'User not found' do
        let(:id) { 9999 }
        run_test!
      end
    end
  end
end
