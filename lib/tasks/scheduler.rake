desc "Update predictions"
task :update_predictions => :environment do
	User.all.each do |u| 
  	puts "Running for #{u.username}"
		u.pick
  	puts "Finished for #{u.username}."
  end
end
