desc "This task updates maps"

task :update => :environment do
  Map.nyt_map
  Map.twitter_map('whedon')
  Map.twitter_map('IBM')
  Map.twitter_map('#openscience')
  Map.twitter_map('asexuality')
  Map.twitter_map('#acepride')
end