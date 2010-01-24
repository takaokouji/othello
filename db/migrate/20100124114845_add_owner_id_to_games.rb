class AddOwnerIdToGames < ActiveRecord::Migration
  def self.up
    add_column(:games, :owner_id, :integer, :null => true)
  end

  def self.down
    remove_column(:games, :owner_id)
  end
end
