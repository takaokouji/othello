# == Schema Information
# Schema version: 20100111055400
#
# Table name: boards
#
#  id              :integer       not null, primary key
#  game_id         :integer
#  position        :integer
#  pieces          :text
#  player_id       :integer
#  players_context :text
#  created_at      :datetime
#  updated_at      :datetime
#

# 盤を表現する。
class Board < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  acts_as_list :scope => :game
  serialize :pieces

  # 初期状態の盤を生成する。
  def self.new_initial_board(game)
    pieces = [
              [game.board_width / 2, game.board_height / 2 - 1, game.first_player_id],
              [game.board_width / 2 - 1, game.board_height / 2, game.first_player_id],
              [game.board_width / 2 - 1, game.board_height / 2 - 1, game.second_player_id],
              [game.board_width / 2, game.board_height / 2, game.second_player_id],
             ]
    return Board.new(:game => game, :position => 1, :pieces => pieces)
  end
end
