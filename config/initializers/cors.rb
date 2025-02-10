Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"  # Change '*' to your frontend domain for security
    resource "/api-docs/",
             headers: :any,
             methods: [ :get, :post, :patch, :put, :delete, :options, :head ]
  end
end
