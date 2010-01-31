class InsertAdminAndGuestToUsers < ActiveRecord::Migration
  def self.up
    if !User.find_by_name("admin")
      user = User.new(:login => "admin", :name => "admin", :password => "qwerty", :password_confirmation => "qwerty", :email => "admin@example.com")
      user.admin = true
      user.save!
    end
    if !User.find_by_name("guest")
      user = User.new(:login => "guest", :name => "guest", :password => "qwerty", :password_confirmation => "qwerty", :email => "guest@example.com")
      user.guest = true
      user.save!
    end
  end

  def self.down
  end
end
