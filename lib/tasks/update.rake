desc "This task updates maps"

task :update => :environment do
  Map.update_all_maps
end