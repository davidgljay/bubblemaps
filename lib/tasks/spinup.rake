desc "Scale up dynos"
require 'heroku-api'

task :spinup => :environment do

  heroku = Heroku::API.new(:username => ENV['heroku_login'], :password => ENV['heroku_pass'])
  heroku.post_ps_scale('bubblemap', 'worker', 1)
end