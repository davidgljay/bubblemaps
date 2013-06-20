desc "Scale down dynos"
require 'heroku-api'
task :spindown => :environment do

  heroku = Heroku::API.new(:username => ENV['heroku_login'], :password => ENV['heroku_pass'])
  heroku.post_ps_scale('bubblemap', 'worker', 0)
end