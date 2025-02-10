require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let!(:user) { User.create!(username: "TestUser") }
  let!(:follower) { User.create!(username: "FollowerUser") }

  describe "associations" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:following).class_name("User") }
  end

  describe "validations" do
    it "validates uniqueness of follower-following pair" do
      Relationship.create!(follower: follower, following: user)
      duplicate_relationship = Relationship.new(follower: follower, following: user)

      expect(duplicate_relationship).not_to be_valid
      expect(duplicate_relationship.errors[:follower_id]).to include("has already been taken")
    end
  end

  describe "counter cache updates" do
    it "increments and decrements follower and following counts" do
      expect { Relationship.create!(follower: follower, following: user) }
        .to change { user.reload.followers_count }.by(1)
        .and change { follower.reload.following_count }.by(1)

      relationship = Relationship.find_by(follower: follower, following: user)
      expect { relationship.destroy }
        .to change { user.reload.followers_count }.by(-1)
        .and change { follower.reload.following_count }.by(-1)
    end
  end
end
