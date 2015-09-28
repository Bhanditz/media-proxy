# @todo use Sinatra?
# @todo use any other stock Rack middlewares?
if ['development', 'test'].include?(ENV['RACK_ENV'])
  require 'dotenv'
  Dotenv.load
end

require 'europeana/api'
require 'europeana/proxy'
require 'logger'

# @todo move into initializer / middleware / etc
unless ENV.key?('EUROPEANA_API_KEY')
  puts 'EUROPEANA_API_KEY must be set in the environment'
  exit 1
end

Europeana::API.api_key = ENV['EUROPEANA_API_KEY']
Europeana::API.url = ENV['EUROPEANA_API_URL'] if ENV['EUROPEANA_API_URL']

logger = Logger.new(STDOUT)
use Rack::CommonLogger, logger

if ENV['CORS_ORIGINS']
  require 'rack/cors'
  use Rack::Cors do
    allow do
      origins ENV['CORS_ORIGINS'].split(' ')
      resource '/*', headers: :any, methods: [:get, :head, :options],
                     expose: ['Content-Length']
    end
  end
end

use Europeana::Proxy::Media

app = Proc.new do |env|
  Europeana::Proxy::Media.response_for_status_code(404)
end

run app
