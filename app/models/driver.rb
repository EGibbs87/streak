class Driver < ActiveRecord::Base
  def self.pick
    agent = Mechanize.new
    
    response = agent.get('http://streak.espn.com/en/entry')
    form = response.form
    form.field_with(:name => "username").value = "Flyersrock87"
    form.field_with(:name => "password").value = "erik1987"
    response = agent.submit(form)
    link = response.link_with(:href => "http://streak.espn.com/en/")
    response = link.click
    
    response = agent.post('https://r.espn.com/members/login', {:username => "Flyersrock87", :password => "erik1987" })
  end
end
