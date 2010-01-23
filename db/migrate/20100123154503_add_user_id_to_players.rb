class AddUserIdToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :user_id, :integer, :null => true
  end

  def self.down
    remove_column :players, :user_id
  end
end
