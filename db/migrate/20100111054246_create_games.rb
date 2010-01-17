class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :time
      t.timestamp :begin_at
      t.timestamp :end_at
      t.integer :first_player_id
      t.integer :second_player_id
      t.integer :board_width
      t.integer :board_height

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
