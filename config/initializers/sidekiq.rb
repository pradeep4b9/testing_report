# encoding: UTF-8
require 'sidekiq'

redis_server = "localhost"

Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://' + redis_server + ':6379/0', namespace: 'mynamespace_mvi' }
  
  config.poll_interval = 15

  # config.server_middleware do |chain|
  #   chain.add Kiqstand::Middleware
  # end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://' + redis_server + ':6379/0', :namespace => 'mynamespace_mvi' }
end