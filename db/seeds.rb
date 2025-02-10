require "faker"

# Clear existing data
puts "Clearing old data..."
User.destroy_all
SleepRecord.destroy_all
Relationship.destroy_all

# Create Users
puts "Creating users..."
users = []
10.times do
  users << User.create!(
    username: Faker::Internet.unique.username,
    created_at: Faker::Time.backward(days: 365)
  )
end

# Create Relationships (Followers/Following)
puts "Creating follow relationships..."
users.each do |user|
  following_users = users.sample(rand(2..5)) - [ user ] # Prevent self-following
  following_users.each do |followed|
    Relationship.find_or_create_by!(follower: user, following: followed)
  end
end

# Create Sleep Records
puts "Creating sleep records..."
users.each do |user|
  rand(5..10).times do
    clock_in = Faker::Time.backward(days: 30, period: :evening)
    clock_out = clock_in + rand(4..10).hours # Random sleep duration

    user.sleep_records.create!(
      clock_in: clock_in,
      clock_out: clock_out
    )
  end
end

puts "Seeding complete! Created #{User.count} users, #{Relationship.count} relationships, and #{SleepRecord.count} sleep records."
