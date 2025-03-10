# Good Night App

A sleep tracking application that helps users log their sleep patterns, connect with friends, and gain insights into their sleeping habits. By following other users, individuals can compare their sleep durations and improve their sleep hygiene together.

## Update

- Optimized caching & pagination for faster responses.
- Removed redundant logic and ensured consistency.
- Fixed test issues and improved API consistency.
- Used caching to reduce database queries and improve scalability.

Now using k6 for load test:
- Installing k6 https://grafana.com/docs/k6/latest/set-up/install-k6/
- Running stress test:
```
k6 run users_stress_test.js
```

## Description
Good Night App allows users to clock in when they go to bed and clock out when they wake up. Users can follow friends to see their sleep records from the past week, ranked by sleep duration. This social approach to sleep tracking encourages better sleep habits and accountability among peers.

## How It Works
- Users log their sleep sessions by clocking in before bed and clocking out when they wake up.
- Users can follow and unfollow friends to monitor their sleep trends.
- A leaderboard displays the sleep records of followed users from the past week, sorted by total sleep duration.

## Addressing Performance Challenges
### N+1 Query Problem
N+1 queries occur when an application fetches records one-by-one instead of using efficient SQL queries. In this app, when retrieving a user's followed sleep records, eager loading (`.includes(:user)`) is used to avoid excessive database queries. Instead of:
```ruby
user.followed_users.each do |friend|
  friend.sleep_records.last
end
```
which triggers an extra query for each followed user, we use:
```ruby
SleepRecord.includes(:user).where(user_id: user.followed_users.select(:id))
```
This approach minimizes database hits, reducing response times and improving scalability.

### Redis & Sidekiq for High-Volume Traffic
To ensure a smooth user experience even under high traffic, the app uses **Sidekiq**, a background job processor backed by **Redis**. Instead of handling sleep session updates synchronously in the main request cycle, tasks are offloaded to Sidekiq to be processed asynchronously. This prevents delays in user interactions.

#### How Sidekiq Handles Sleep Session Updates
When a user starts or stops sleep, the `SleepRecordJob` is enqueued with Sidekiq:
```ruby
SleepRecordJob.perform_later(user.id, :start_sleep)
```
Inside the job, the correct action (`start_sleep` or `stop_sleep`) is triggered by calling the `SleepRecordsService`. This ensures sleep tracking operations run smoothly, even under high user load, without blocking other requests.

## Installation
### Prerequisites
Ensure you have the following installed:
- Ruby (~> 3.2)
- Rails (~> 8.0.1)
- PostgreSQL
- Redis (for background jobs with Sidekiq)

### Setup
1. Clone the repository:
   ```sh
   git clone https://github.com/hudaswanditya/good_night_api.git
   cd good_night_api
   ```
2. Install dependencies:
   ```sh
   bundle install
   ```
3. Set up the database:
   ```sh
   rails db:create db:migrate db:seed
   ```
4. Start Redis (for Sidekiq jobs):
   ```sh
   redis-server
   ```
5. Start the Rails server:
   ```sh
   rails server
   ```
6. Start Sidekiq (for background jobs):
   ```sh
   bundle exec sidekiq
   ```

## API Endpoints
### Users
- `GET /api/v1/users` - Retrieve a list of users.
- `GET /api/v1/users/:id` - Retrieve user details.
- `POST /api/v1/users/:id/follow/:target_user_id` - Follow a user.
- `DELETE /api/v1/users/:id/unfollow/:target_user_id` - Unfollow a user.
- `GET /api/v1/users/:id/followers` - Get a list of followers.
- `GET /api/v1/users/:id/following` - Get a list of followed users.
- `GET /api/v1/users/:id/following_sleep_records` - Retrieve sleep records of followed users.

### Sleep Records
- `GET /api/v1/users/:user_id/sleep_records` - Retrieve a list of sleep records.
- `POST /api/v1/users/:user_id/sleep_records/start_sleep` - Start a sleep record.
- `PATCH /api/v1/users/:user_id/sleep_records/stop_sleep` - Stop a sleep record.
- `POST /api/v1/users/:user_id/sleep_records` - Create a sleep record.

## Development
### Running Tests
Run the test suite with:
```sh
bundle exec rspec
```

### Code Quality & Security
- **Linting:** `bundle exec rubocop`
- **Security Checks:** `bundle exec brakeman`

## Technologies Used
- **Rails 8** - Web framework
- **PostgreSQL** - Database
- **Sidekiq & Redis** - Background job processing
- **Rack Attack** - Rate limiting security
- **RSpec & FactoryBot** - Testing suite

## Contributing
1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request.

## License
This project is licensed under the MIT License.

