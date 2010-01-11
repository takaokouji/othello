class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.timestamp :begin_at
      t.timestamp :end_at
      t.integer :first_player_id
      t.integer :second_player_id

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
