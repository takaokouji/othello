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
    last_board = boards.last
    if last_board.player && last_board.player == first_player
      player = second_player
    else
      player = first_player
    end

    # 次に駒を置くことができる位置の配列を求める。
    candidates = last_board.candidates(player)

    # Playerのsolveメソッドで使うためのcontextを用意する。
    #   contextに格納する要素
    #   * pieces: 既存。配列の配列になっていること。
    #   * candidates: おける場所
    context = Context.new(last_board.pieces, candidates)

    # solveをevalする。(Player#solve(context))
    player.load_ai
    player.solve(context)

    if context.next_piece
      # contextに設定された駒の位置から新しいBoard(pieces)を作る。
      pieces = last_board.set_piece(player, *context.next_piece)
    else
      # contextに設定されていない場合はパスだとみなす。
      pieces = last_board.pieces
    end
    boards.create(:player => player, :players_context => {}, :pieces => pieces)
  end

  # solveメソッドに渡すコンテキストを表現する。
  class Context
    attr_reader :pieces
    attr_reader :candidates
    attr_reader :next_piece
    
    def initialize(pieces, candidates)
      @pieces = []
      pieces.each do |piece|
        @pieces << piece.dup
      end
      @candidates = candidates
      @next_piece = nil
    end

    def set_next_piece(x, y)
      @next_piece = [x, y]
    end
  end

  private
  
  def init_board
    if boards.empty?
      boards.push(Board.new_initial_board(self))
    end
    return true
  end
end
