source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cable"

gem "redis"
gem "sidekiq" # Background jobs
gem "rack-attack" # Rate limiting

gem "bootsnap", require: false
gem "kamal", require: false

gem "rack-cors"

group :development do
  gem "brakeman", require: false
end

group :development, :test do
  gem "debug", require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"

  gem "shoulda-matchers"

  gem "rswag"
end
