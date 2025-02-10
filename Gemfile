source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false

# If API is used by a separate frontend (React, Vue, etc.), you need CORS
# gem "rack-cors"

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
end
