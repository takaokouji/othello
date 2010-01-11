class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
      t.integer :game_id
      t.integer :position
      t.text :pieces
      t.integer :player_id
      t.text :players_context

      t.timestamps
    end
  end

  def self.down
    drop_table :boards
  end
end
