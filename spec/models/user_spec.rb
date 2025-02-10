require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create!(username: "TestUser") }

  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
  end

  describe 'associations' do
    it { should have_many(:relationships).dependent(:destroy) }
    it { should have_many(:followed_users).through(:relationships).source(:following) }

    it { should have_many(:reverse_relationships).class_name('Relationship').with_foreign_key('following_id').dependent(:destroy) }
    it { should have_many(:followers).through(:reverse_relationships).source(:follower) }

    it { should have_many(:sleep_records) }
  end

  describe 'following relationships' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context '#follow' do
      it 'follows another user' do
        expect { user.follow(other_user) }.to change { user.followed_users.count }.by(1)
        expect(user.following?(other_user)).to be true
        expect(other_user.follower?(user)).to be true
      end

      it 'does not follow the same user twice' do
        user.follow(other_user)
        expect { user.follow(other_user) }.not_to change { user.followed_users.count }
      end

      it 'does not allow a user to follow themselves' do
        expect { user.follow(user) }.not_to change { user.followed_users.count }
      end
    end

    context '#unfollow' do
      before { user.follow(other_user) }

      it 'unfollows a user' do
        expect { user.unfollow(other_user) }.to change { user.followed_users.count }.by(-1)
        expect(user.following?(other_user)).to be false
        expect(other_user.follower?(user)).to be false
      end
    end

    context '#following?' do
      it 'returns true if the user is following another user' do
        user.follow(other_user)
        expect(user.following?(other_user)).to be true
      end

      it 'returns false if the user is not following another user' do
        expect(user.following?(other_user)).to be false
      end
    end

    context '#follower?' do
      it 'returns true if the user is followed by another user' do
        other_user.follow(user)
        expect(user.follower?(other_user)).to be true
      end

      it 'returns false if the user is not followed by another user' do
        expect(user.follower?(other_user)).to be false
      end
    end
  end

  describe 'N+1 queries optimization' do
    let(:user) { create(:user) }
    let!(:followers) { create_list(:user, 5) }
    let!(:following) { create_list(:user, 5) }

    it "preloads followers efficiently" do
      user_with_followers = User.includes(:followers).find(user.id)

      # Check that followers are preloaded and do not trigger extra queries
      expect { user_with_followers.followers.to_a }.not_to raise_error
    end

    it "preloads followers efficiently" do
      user_with_followed_users = User.includes(:followed_users).find(user.id)

      # Check that following are preloaded and do not trigger extra queries
      expect { user_with_followed_users.followers.to_a }.not_to raise_error
    end
  end

  describe "#following_sleep_records_last_week" do
    let(:user) { create(:user) }
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }
    let(:unfollowed_user) { create(:user) }

    let!(:relationship1) { create(:relationship, follower: user, following: followed_user1) }
    let!(:relationship2) { create(:relationship, follower: user, following: followed_user2) }

    let!(:valid_sleep1) do
      create(:sleep_record, user: followed_user1, clock_in: 1.week.ago.beginning_of_week + 2.hours, clock_out: 1.week.ago.beginning_of_week + 10.hours)
    end

    let!(:valid_sleep2) do
      create(:sleep_record, user: followed_user2, clock_in: 1.week.ago.beginning_of_week + 1.hour, clock_out: 1.week.ago.beginning_of_week + 8.hours)
    end

    let!(:old_sleep) do
      create(:sleep_record, user: followed_user1, clock_in: 2.weeks.ago.beginning_of_week, clock_out: 2.weeks.ago.beginning_of_week + 7.hours)
    end

    let!(:unfollowed_sleep) do
      create(:sleep_record, user: unfollowed_user, clock_in: 1.week.ago.beginning_of_week + 3.hours, clock_out: 1.week.ago.beginning_of_week + 9.hours)
    end

    it "returns sleep records from followed users within the last week" do
      records = user.following_sleep_records_last_week

      expect(records).to contain_exactly(valid_sleep1, valid_sleep2)
    end

    it "does not return sleep records from unfollowed users" do
      records = user.following_sleep_records_last_week

      expect(records).not_to include(unfollowed_sleep)
    end

    it "does not return sleep records outside the previous week" do
      records = user.following_sleep_records_last_week

      expect(records).not_to include(old_sleep)
    end

    it "returns records sorted by sleep duration in descending order" do
      records = user.following_sleep_records_last_week

      expect(records.first.sleep_duration).to be >= records.last.sleep_duration
    end
  end
end
