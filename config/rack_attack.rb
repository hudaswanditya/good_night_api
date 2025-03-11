class Rack::Attack
  throttle("limit sleep requests", limit: 10, period: 60.seconds) do |req|
    if req.path.match?(/\/api\/v1\/users\/\d+\/sleep_records\/(start|stop)/)
      req.ip # Rate limit by IP
    end
  end

  self.throttled_response = lambda do |_env|
    [ 429, { "Content-Type" => "application/json" }, [ { status: "error", message: "Too many requests. Slow down!" }.to_json ] ]
  end
end
