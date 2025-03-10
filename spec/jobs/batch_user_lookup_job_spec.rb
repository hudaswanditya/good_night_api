require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake! # Ensures jobs are stored in the test queue

RSpec.describe BatchUserLookupJob, type: :job do
  let!(:users) { create_list(:user, 3) }
  let(:user_ids) { users.map(&:id) }
  let(:cache_keys) { users.map { |user| "user_#{user.id}" } }

  before do
    cache_keys.each { |key| Rails.cache.delete(key) } # Ensure cache is empty before test
  end

  it 'queues the job' do
    expect {
      BatchUserLookupJob.perform_async(user_ids)
    }.to change(BatchUserLookupJob.jobs, :size).by(1) # Ensure job is queued
  end

  it 'fetches and caches users asynchronously' do
  BatchUserLookupJob.perform_async(user_ids)
  BatchUserLookupJob.drain # Ensure Sidekiq processes the job

  users.each do |user|
    cached_user = Rails.cache.read("user_#{user.id}")
    puts "DEBUG: Cached user - #{cached_user.inspect}" # Debugging line

    expect(cached_user).to be_present
    expect(cached_user["id"]).to eq(user.id)
  end
end


  it 'does not cache non-existing users' do
    non_existing_ids = [ 9999, 8888 ]

    BatchUserLookupJob.perform_async(non_existing_ids)
    BatchUserLookupJob.drain

    non_existing_ids.each do |id|
      expect(Rails.cache.read("user_#{id}")).to be_nil
    end
  end
end
