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
    context = Context.new(self, player, last_board.pieces, candidates)
    last_players_board = boards.find(:first, :conditions => ["player_id = ?", player.id], :order => "position DESC")
    if last_players_board
      context.instance_variable_set(:@context, last_players_board.players_context)
    end

    # solveをevalする。(Player#solve(context))
    begin
      player.load_ai
      start_time = Time.now
      end_time = start_time + last_board.next_time
      context.instance_variable_set(:@next_time, end_time)
      Timeout.timeout(last_board.next_time) do
        t = Thread.start {
          $SAFE = 3
          player.solve(context)
        }
        t.join
        sleep(end_time - start_time) if RAILS_ENV != "test"
      end
    rescue Exception => e
      if !e.is_a?(Timeout::Error)
        logger.debug(e.inspect)
        logger.debug(e.backtrace.join("\n"))
      end
    end

    if context.context.is_a?(Hash) && context.context.length > 0
      players_context = context.context
    else
      players_context = {}
    end

    pieces = last_board.pieces
    begin
      players_piece_x, players_piece_y = *context.next_piece
      pieces = last_board.set_piece(player, *context.next_piece)
    rescue ArgumentError
    end
    boards.create(:player => player, :players_piece_x => players_piece_x, :players_piece_y => players_piece_y, :players_context => players_context, :pieces => pieces, :next_time => calc_next_time)
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
  
  # プレイヤーが最後に打った手を記録したBoardを取得する。
  def last_players_board(player)
    return boards.find(:first, :conditions => ["player_id = ?", player.id], :order => "position DESC")
  end

  # solveメソッドに渡すコンテキストを表現する。
  class Context
    attr_reader :game
    attr_reader :player
    attr_reader :pieces
    attr_reader :candidates
    attr_reader :next_piece
    attr_reader :next_time
    attr_reader :context
    
    def initialize(game, player, pieces, candidates)
      @game = game
      @player = player
      @pieces = Array.new(game.board_width) { |i| Array.new(game.board_height) }
      pieces.each do |x, y, player_id|
        @pieces[x][y] = (@player.id == player_id)
      end
      @candidates = candidates
      @next_piece = nil
      @context = {}
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

    def rival
      return game.first_player == @player ? game.second_player : game.first_player
    end
    
    # 相手が前回打った手の位置(x,y)を取得する。
    def rivals_previous_piece
      board = game.last_players_board(rival)
      return board ? [board.players_piece_x, board.players_piece_y] : nil
    end

    private

    def pieces_to_board(pieces)
      board_pieces = []
      pieces.each_with_index do |row, x|
        row.each_with_index do |player, y|
          target_player = flag_to_player(player)
          if target_player
            board_pieces << [x, y, target_player.id]
          end
        end
      end
      return Board.new(:game => @game, :pieces => board_pieces)
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
