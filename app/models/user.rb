class User < ActiveRecord::Base
  def pick
    retries = 0
    begin
      driver = Selenium::WebDriver.for :phantomjs
      
      # Set wait function to allow browser time to react
      wait = Selenium::WebDriver::Wait.new(:timeout => 20)
  
      # Go to streak page
      driver.navigate.to 'http://streak.espn.com/en/entry'
      
      # if current time is after or substantially before start times, end script without logging in
      matchups = wait.until { driver.find_elements(:class, 'matchup-container') }
      times = matchups.map { |m| m.find_element(:class, "startTime").attribute('data-locktime').to_datetime }
      start = times[0]
      finish = times[-1]
      now = DateTime.now.in_time_zone("Eastern Time (US & Canada)")
      if (now + 30.minutes) < start
        puts "Too early; closing"
        driver.close
        return true
      elsif now > finish
        puts "No more games; closing"
        driver.close
        return true
      else
        puts "Checking games..."
      end
      
      # LOG INTO ESPN
      puts "Logging in..."
      user_module = wait.until { driver.find_element(:class, 'user') }
      login_button = wait.until { user_module.find_element(:tag_name, 'a') }
      
      wait.until { login_button.click }
      
      wait.until { driver.switch_to.frame('disneyid-iframe') }
      
      fields = wait.until { driver.find_elements(:tag_name, 'input') }
      retries2 = 0
      begin
        fields.find { |f| f.attribute('placeholder')['Username'] }.send_keys self.username
        fields.find { |f| f.attribute('placeholder')['Password'] }.send_keys self.password
      rescue
        if retries2 < 20
          retries2 += 1
          puts "Login failed; trying again (#{retries2})"
          sleep(1)
          retry
        else
          puts "Failed to log in"
          driver.close
          return false
        end
      end
      submit = wait.until { driver.find_elements(:tag_name, 'button').select { |b| b.text == "Log In" }[0] }
      wait.until { submit.click }
      puts "Successful login submission; verifying login."
      driver.switch_to.default_content
      
      # Wait until site is done fully rendering
      sleep(20)
      
      # Run check to make sure login took
      check = wait.until { driver.find_elements(:tag_name, 'a').map { |a| a.text } }
      if check.include?("My Entry")
        puts "Logged in; continuing"
      else
        raise
      end
    rescue
      if retries < 5
        puts "Login failed; trying again (#{retries})"
        driver.close
        retries += 1
        retry
      else
        puts "Login failed 5 times; Closing."
        driver.close
        return false
      end
    end
    
    # Close if a pick is already active
    #### maybe use class pendingpick if it disappears when there is none
    puts "Checking to see that there are no current pending picks..."
    retries = 0
    begin
      if wait.until { driver.find_elements(:class, 'mg-gametableQYlw').empty? }
        puts "No picks currently pending.  Processing selection..."
      else
        puts "Pick has already been made!  Closing"
        driver.close
        return true
      end
    rescue
      if retries < 10
        puts "Retrying (#{retries})"
        retries += 1
        retry
      else
        puts "Failed to find elements 10 times"
        driver.close
        return false
      end
    end
    
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
    
    # Select trends tables of eligible matchups
    trends = matchups.map { |m| wait.until { m.find_elements(:class, 'wpw').map { |c| c.text.to_f }.uniq } }
    
    # Find the first matchup in which [THRESHOLD]% of people are selecting one winner
    target = trends.find { |t| t[0] > self.threshold || t[1] > self.threshold }
    
    # Find index of the predicted winner
    target[0] > target[1] ? target_selection_index = 0 : target_selection_index = 1
    
    # Find findex of target matchup
    target_index = trends.index(target)
    
    # Maybe add something that only picks on "hot" or "warmer" entries
    
    # Find target checkbox table element
    select_game =  wait.until { matchups[target_index].find_elements(:class, 'pick')[target_selection_index] }
    
    # Find target checkbox
    checkbox = wait.until { select_game.find_element(:tag_name, 'a') }
    
    # Select prediction
    wait.until { checkbox.click }
    puts "Game has been selected!"
    
    # Close driver
    driver.close
  end
end
