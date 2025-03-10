require 'rails_helper'

RSpec.describe BatchUserLookupJob, type: :job do
  describe '#perform' do
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }
    let!(:user_3) { create(:user) }

    it 'writes the users to the cache' do
      user_ids = [ user_1.id, user_2.id, user_3.id ]

      expect(Rails.cache).to receive(:write).with("user_#{user_1.id}", anything, expires_in: 10.minutes)
      expect(Rails.cache).to receive(:write).with("user_#{user_2.id}", anything, expires_in: 10.minutes)
      expect(Rails.cache).to receive(:write).with("user_#{user_3.id}", anything, expires_in: 10.minutes)

      BatchUserLookupJob.perform_now(user_ids)
    end

    it 'fetches users from the database' do
      user_ids = [ user_1.id, user_2.id, user_3.id ]

      expect(User).to receive(:where).with(id: user_ids).and_call_original
      BatchUserLookupJob.perform_now(user_ids)
    end
  end
end
