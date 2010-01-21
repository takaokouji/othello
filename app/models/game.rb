# -*- coding: utf-8 -*-
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

require "timeout"

class Game < ActiveRecord::Base
  has_many :boards, :order => :position
  belongs_to :first_player, :class_name => "Player"
  belongs_to :second_player, :class_name => "Player"
  before_save :init_board

  # 次の手の持ち時間を取得する。
  def calc_next_time
    return rand(15) + 1
  end

  # ゲームを開始する。
  def start
    # TODO: すでにbegin_atとend_atが設定されていた場合は例外。
    begin_at = Time.now
    end_at = begin_at + time * 60
    save!
  end

  # ゲームを停止する。
  def stop
    if end_at.nil?
      end_at = Time.now
      save!
    end
  end

  # 次の一手を打つ。
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
    # contextに格納する要素は以下。
    # * pieces: 既存。配列の配列になっていること。
    # * candidates: おける場所
    # * next_time: 持ち時間
    context = Context.new(self, player, last_board.pieces, candidates, last_board.next_time)

    # solveをevalする。(Player#solve(context))
    begin
      player.load_ai
      start_time = Time.now
      end_time = start_time + last_board.next_time
      Timeout.timeout(last_board.next_time) do
        player.solve(context)
        sleep(end_time - start_time) if RAILS_ENV != "test"
      end
    rescue Exception => e
      logger.debug(e.inspect)
    end

    if context.next_piece
      # contextに設定された駒の位置から新しいBoard(pieces)を作る。
      pieces = last_board.set_piece(player, *context.next_piece)
    else
      # contextに設定されていない場合はパスだとみなす。
      pieces = last_board.pieces
    end
    boards.create(:player => player, :players_context => {}, :pieces => pieces, :next_time => calc_next_time)
  end

  # solveメソッドに渡すコンテキストを表現する。
  class Context
    attr_reader :game
    attr_reader :player
    attr_reader :pieces
    attr_reader :candidates
    attr_reader :next_piece
    attr_reader :next_time
    
    def initialize(game, player, pieces, candidates, next_time)
      @game = game
      @player = player
      @pieces = Array.new(game.board_width) { |i| Array.new(game.board_height) }
      pieces.each do |x, y, player_id|
        @pieces[x][y] = player_id
      end
      @candidates = candidates
      @next_time = next_time
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
