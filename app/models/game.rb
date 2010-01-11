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

  def next_piece
    # 次に駒を置くことができる位置の配列を求める。
    # Playerのsolveメソッドで使うためのcontextを用意する。
    #   contextに格納する要素
    #   * pieces: 既存。配列の配列になっていること。
    #   * candidate: おける場所
    # solveをevalする。(Player#solve(context))
    # contextに設定された駒の位置から新しいBoard(pieces)を作る。
    pieces = [
              [board_width / 2 - 1, board_height / 2 - 2, first_player_id],
              [board_width / 2, board_height / 2 - 1, first_player_id],
              [board_width / 2 - 1, board_height / 2, first_player_id],
              [board_width / 2 - 1, board_height / 2 - 1, first_player_id],
              [board_width / 2, board_height / 2, second_player_id],
             ]
    boards.create(:player => first_player, :players_context => {}, :pieces => pieces)
  end

  private
  
  def init_board
    if boards.empty?
      boards.push(Board.new_initial_board(self))
    end
    return true
  end
end
