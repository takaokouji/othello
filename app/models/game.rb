# == Schema Information
# Schema version: 20100111055400
#
# Table name: games
#
#  id               :integer       not null, primary key
#  begin_at         :datetime
#  end_at           :datetime
#  first_player_id  :integer
#  second_player_id :integer
#  board_width      :integer
#  board_height     :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Game < ActiveRecord::Base
  has_many :boards, :order => :position
  belongs_to :first_player, :class_name => "Player"
  belongs_to :second_player, :class_name => "Player"
  before_save :init_board

  def init_board
    if boards.empty?
      boards.push(Board.new_initial_board(self))
    end
    return true
  end
end
