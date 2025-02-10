class Rack::Attack
  # Limit API requests to 60 per minute per user
  throttle("api/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end
end
