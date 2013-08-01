require 'twitter'

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_KEY']
  config.consumer_secret = ENV['TWITTER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OATH_TOKEN_SECRET']
  config.connection_options = Twitter::Default::CONNECTION_OPTIONS.merge(:request => {
      :open_timeout => 5,
      :timeout => 10
  })
end