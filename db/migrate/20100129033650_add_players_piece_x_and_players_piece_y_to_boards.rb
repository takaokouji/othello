class AddPlayersPieceXAndPlayersPieceYToBoards < ActiveRecord::Migration
  def self.up
    add_column(:boards, :players_piece_x, :integer)
    add_column(:boards, :players_piece_y, :integer)
  end

  def self.down
    remove_column(:boards, :players_piece_x)
    remove_column(:boards, :players_piece_y)
  end
end
