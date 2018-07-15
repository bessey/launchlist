ROM::Rails::Railtie.configure do |config|
  credentials = Web::Application.credentials.database
  config.gateways[:default] = [:sql, credentials]
end
