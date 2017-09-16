class Match < ActiveRecord::Base
  def self.get_historical_data(pages, start_date)
  	# start_date is YYYYMMDD
  	matches = Match.all
    driver = Selenium::WebDriver.for :phantomjs
    
    # Set wait function to allow browser time to react
    wait = Selenium::WebDriver::Wait.new(:timeout => 20)

    # Go to streak page
    puts "Going to streak page..."
    base = 'http://streak.espn.com/en/entry'
    date = start_date.nil? ? '' : "/?date=#{start_date}"
		driver.navigate.to  base + date
		
		pages.times do |i|
			puts "Finding matchups for page #{i + 1}..."
	    retries = 0
	    begin
	      # Find matchups to select
	      matchups = driver.find_elements(:class, 'matchup-container')
	    rescue
	      if retries < 100
	        puts "Couldn't find matchup containers; retrying (#{retries})"
	        retries += 1
	        sleep(1)
	        retry
	      else
	        puts "Failed to find matchup containers 100 times; Closing."
	        driver.close
	        return false
	      end
	    end
	    
	    date = wait.until { driver.find_element(:class, 'date').text }
	    puts "Checking for matches with date #{date}"
	    if !matches.find_by(date: date).nil?
	    	puts "Matches already exist for this date; moving to next date..."
		    prev_page = driver.find_element(:class, 'prev-date')
		    prev_page.find_element(:tag_name, 'a').click
	    	next
	    end
	    
	    puts "Saving matchups in array of hashes..."
	    matchups_array = matchups.map { |m| {
	    	:description => wait.until { m.find_element(:class, 'gamequestion') }.text, # description
	    	:sport => wait.until { m.find_element(:class, 'sport-description') }.text, # sport
	    	:options => wait.until { m.find_elements(:class, 'opponents') }.map { |o| o.text }, # options
	    	:winner => wait.until { m.find_elements(:class, 'winner') }.map { |w| w.text }.index(""), # winner is ""? # winner
	    	:option_finals => wait.until { m.find_elements(:class, 'result') }.map { |r| r.text }, # option_finals
	    	:option_chosens => wait.until { m.find_elements(:class, 'wpw') }.map { |w| w.text }.uniq, # option_chosens
	    	:heat => wait.until { m.find_element(:class, 'progress-bar') }.attribute('title'), # heat
	    	:comments_count => wait.until { m.find_element(:class, 'comments-count') }.text # comments count
	    }}
	    
	    puts "Saving matchups for #{date}..."
	    matchups_array.each do |m|
	    	heat_regex = m[:heat].match(/This matchup had (.*)% of all active picks/)
	    	heat = heat_regex.nil? ? m[:heat] : heat_regex[1]
	    	Match.where(
	    		sport: m[:sport], 
	    		description: m[:description], 
	    		first_option: m[:options][0], 
	    		second_option: m[:options][1], 
	    		winner: m[:winner],
	    		heat: heat,
	    		first_option_chosen: m[:option_chosens][0],
	    		second_option_chosen: m[:option_chosens][1],
	    		first_final: m[:option_finals][0],
	    		second_final: m[:option_finals][1],
	    		comments_count: m[:comments_count],
	    		date: date
	  		).first_or_create
	    end
	    
	    prev_page = driver.find_element(:class, 'prev-date')
	    
	    puts "Finished importing games for #{date}; moving to #{prev_page.text}"
	    
	    prev_page.find_element(:tag_name, 'a').click
    end
    
    puts "Finished importing all #{pages} pages of data!"
    # Close driver
    driver.close
  end
end
