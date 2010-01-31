# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20100129033650
#
# Table name: boards
#
#  id              :integer       not null, primary key
#  game_id         :integer
#  position        :integer
#  pieces          :text
#  player_id       :integer
#  players_context :text
#  next_time       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  players_piece_x :integer
#  players_piece_y :integer
#

# 盤を表現する。
class Board < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  acts_as_list :scope => :game
  serialize :pieces
  serialize :players_context

  # +player+ が配置できる位置を配列で取得する。
  def candidates(player)
    candidates = []
    
    # 相手の駒に隣接している位置を全て取得する。
    pieces.each do |x, y, player_id|
      if player.id != player_id
        DIRECTIONS.each do |dx, dy|
          cx = x + dx
          cy = y + dy
          if cx >= 0 && cx < game.board_width && cy >= 0 && cy < game.board_height
            candidates << [cx, cy]
          end
        end
      end
    end
    candidates.uniq!
    
    # 上記からすでに駒が配置されている位置を取り除く。
    candidates -= pieces.collect { |x, y,| [x, y] }

    if candidates.length > 0
      # 残った位置の中から駒を置いても相手の駒を反転できない位置を取り除く。
      candidates = candidates.delete_if { |c|
        count_changed_pieces(player, *c) == 0
      }
    end

    if candidates.empty?
      # TODO: まったく配置する位置がなければどこでも配置できる。
    end

    return candidates.sort { |c1, c2|
      c1[1] == c2[1] ? c1[0] <=> c2[0] : c1[1] <=> c2[1]
    }
  end

  # +player+ の駒を +x+ と +y+ の位置に配置した結果、変化する相手の駒の配列を返す。
  def changed_pieces(player, x, y)
    if pieces.detect { |px, py,| px == x && py == y }
      raise ArgumentError
    end
    res = []
    DIRECTIONS.each do |dx, dy|
      changed = []
      cx = x
      cy = y
      loop do
        cx += dx
        cy += dy
        if !(cx >= 0 && cx < game.board_width && cy >= 0 && cy < game.board_height)
          changed.clear
          break
        end
        piece = pieces.detect { |px, py,|
          px == cx && py == cy
        }
        if piece.nil?
          changed.clear
          break
        elsif piece[2] == player.id
          break
        else
          changed << [cx, cy]
        end
      end
      res += changed
    end
    return res
  end

  # +player+ が +x+ と +y+ の位置に駒を配置した場合に相手の駒が入れ替わる数を取得する。
  def count_changed_pieces(player, x, y)
    if pieces.detect { |px, py,| px == x && py == y }
      raise ArgumentError
    end
    return changed_pieces(player, x, y).length
  end

  # +player+ の駒を +x+ と +y+ の位置に配置した結果の盤を返す。
  def set_piece(player, x, y)
    if count_changed_pieces(player, x, y) == 0
      raise ArgumentError
    end
    res = pieces.collect { |piece| piece.dup }
    changed_pieces(player, x, y).each do |cpx, cpy|
      piece = res.detect { |px, py,|
        px == cpx && py == cpy
      }
      piece[2] = player.id
    end
    res << [x, y, player.id]
    return res
  end

  # 初期状態の盤を生成する。
  def self.new_initial_board(game)
    pieces = [
              [game.board_width / 2, game.board_height / 2 - 1, game.first_player_id],
              [game.board_width / 2 - 1, game.board_height / 2, game.first_player_id],
              [game.board_width / 2 - 1, game.board_height / 2 - 1, game.second_player_id],
              [game.board_width / 2, game.board_height / 2, game.second_player_id],
             ]
    return Board.new(:game => game, :position => 1, :pieces => pieces, :next_time => game.calc_next_time)
  end

  private

  # ピースを置いた際、反転できるピースを検索する方向（8方向）を
  # 定義する
  DIRECTIONS = [
                [-1, -1], # 左上
                [0, -1], # 上
                [1, -1], # 右上
                [-1, 0], # 左
                [1, 0], # 右
                [-1, 1], # 左下
                [0, 1], # 下
                [1,1], # 右下
               ]
end
