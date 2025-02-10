require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) } # Uses FactoryBot to create test data

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a name" do
    subject.username = nil
    expect(subject).not_to be_valid
  end

  context "when a user with the same name exists" do
    before { create(:user, username: subject.username) }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end
end
