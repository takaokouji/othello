class AddEnableToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :enable, :boolean, :default => false
  end

  def self.down
    remove_column :players, :enable
  end
end
