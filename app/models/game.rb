# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20100124114845
#
# Table name: games
#
#  id               :integer       not null, primary key
#  time             :integer
#  begin_at         :datetime
#  end_at           :datetime
#  first_player_id  :integer
#  second_player_id :integer
#  board_width      :integer
#  board_height     :integer
#  created_at       :datetime
#  updated_at       :datetime
#  owner_id         :integer
#

require "timeout"

class Game < ActiveRecord::Base
  has_many :boards, :order => :position
  belongs_to :owner, :class_name => "Player"
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
    self.begin_at = Time.now
    self.end_at = begin_at + time * 60
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
    context = Context.new(self, player, last_board.pieces, candidates)

    # solveをevalする。(Player#solve(context))
    begin
      player.load_ai
      start_time = Time.now
      end_time = start_time + last_board.next_time
      context.instance_variable_set(:@next_time, end_time)
      Timeout.timeout(last_board.next_time) do
        player.solve(context)
        sleep(end_time - start_time) if RAILS_ENV != "test"
      end
    rescue Exception => e
      logger.debug(e.inspect)
      logger.debug(e.backtrace.join("\n"))
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
  
  # ゲームの残り時間を取得する。
  def left_sec
    return end_at - Time.now
  end
  
  # ゲームが終了しているかどうかを取得する。
  def timeup?
    if Time.now >= end_at
      return true
    end
    return boards.last.pieces.length >= board_width * board_height
  end
  
  # ゲームの勝者を取得する。引き分けの場合はnilを返す。
  def winner
    last_board = boards.last
    player_id_pieces = last_board.pieces.group_by { |piece| piece[2] }
    first_player_pieces = player_id_pieces[first_player_id]
    second_player_pieces = player_id_pieces[second_player_id]
    case first_player_pieces.length <=> second_player_pieces.length
    when 1
      return first_player
    when -1
      return second_player
    else
      return nil
    end
  end

  # solveメソッドに渡すコンテキストを表現する。
  class Context
    attr_reader :game
    attr_reader :player
    attr_reader :pieces
    attr_reader :candidates
    attr_reader :next_piece
    attr_reader :next_time
    
    def initialize(game, player, pieces, candidates)
      @game = game
      @player = player
      @pieces = Array.new(game.board_width) { |i| Array.new(game.board_height) }
      pieces.each do |x, y, player_id|
        @pieces[x][y] = (@player.id == player_id)
      end
      @candidates = candidates
      @next_piece = nil
    end
    
    def left_sec
      return @game.left_sec
    end
    
    def set_next_piece(x, y)
      @next_piece = [x, y]
    end

    def count_changed_pieces(player, pieces, x, y)
      board = pieces_to_board(pieces)
      return board.count_changed_pieces(flag_to_player(player), x, y)
    end

    def changed_pieces(player, pieces, x, y)
      board = pieces_to_board(pieces)
      return board.changed_pieces(flag_to_player(player), x, y)
    end

    def next_candidates(player, pieces)
      board = pieces_to_board(pieces)
      return board.candidates(flag_to_player(player))
    end

    private

    def pieces_to_board(pieces)
      boards_pieces = []
      pieces.each do |x, y, player|
        target_player = flag_to_player(player)
        if target_player
          boards_pieces << [x, y, target_player.id]
        end
      end
      return Board.new(:game => @game, :pieces => boards_pieces)
    end

    def flag_to_player(flag)
      case flag
      when true
        return @player
      when false
        return @game.first_player == @player ? @game.second_player : @game.first_player
      else
        return nil
      end
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
