class AddGuestToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :guest, :boolean, :default => false)
    execute("UPDATE users SET guest = 'F'")
  end

  def self.down
    remove_column(:users, :guest)
  end
end
