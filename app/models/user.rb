class User < ActiveRecord::Base
	def pick
    driver = Selenium::WebDriver.for :phantomjs
    
    # Set wait function to allow browser time to react
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)

    # Go to streak page
    driver.navigate.to 'http://streak.espn.com/en/entry'
    
    # LOG INTO ESPN
    user_module = wait.until { driver.find_element(:class, 'user') }
    login_button = wait.until { user_module.find_element(:tag_name, 'a') }
    
    wait.until { login_button.click }
    
    wait.until { driver.switch_to.frame('disneyid-iframe') }
    
    fields = wait.until { driver.find_elements(:tag_name, 'input') }
    retries = 0
    begin
      fields.find { |f| f.attribute('placeholder')['Username'] }.send_keys self.username
      fields.find { |f| f.attribute('placeholder')['Password'] }.send_keys self.password
    rescue
      if retries < 20
        retries += 1
        retry
      else
        puts "failed"
      end
    end
    submit = wait.until { driver.find_elements(:tag_name, 'button').select { |b| b.text == "Log In" }[0] }
    wait.until { submit.click }
    driver.switch_to.default_content
    
    # Wait until site is done fully rendering
    sleep(10)
    
    # Find matchups to select
    matchups = wait.until { driver.find_elements(:class, 'matchup-container') }
    
    # Select trends tables of eligible matchups
    trends = matchups.map { |m| wait.until { m.find_elements(:class, 'wpw').map { |c| c.text.to_f }.uniq } }
    
    # Find the first matchup in which [THRESHOLD]% of people are selecting one winner
    target = trends.find { |t| t[0] > self.threshold || t[1] > self.threshold }
    
    # Find index of the predicted winner
    target[0] > target [1] ? target_selection_index = 0 : target_selection_index = 1
    
    # Find findex of target matchup
    target_index = trends.index(target)
    
    # Maybe add something that only picks on "hot" or "warmer" entries
    
    # Find target checkbox table element
    select_game =  wait.until { matchups[target_index].find_elements(:class, 'pick')[target_selection_index] }
    
    # Find target checkbox
    checkbox = wait.until { select_game.find_element(:tag_name, 'a') }
    
    # Select prediction
    wait.until { checkbox.click }
    
    # Close driver
    driver.close
	end
end
