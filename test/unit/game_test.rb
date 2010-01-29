# -*- coding: utf-8 -*-
require 'test_helper'
require "game"

class GameTest < ActiveSupport::TestCase
  test "Game.save:盤が設定されていれば初期状態の盤は設定しない。" do
    game = games(:game1)
    game.save!
    assert_boards_equal([Board.new_initial_board(game)], game.boards)
  end

  test "Game.save:盤がまだ設定されていなければ初期状態の盤を設定する。" do
    game = Game.create!(:board_width => 50, :board_height => 50, :first_player => players(:player1), :second_player => players(:player2))
    assert_boards_equal([Board.new_initial_board(game)], game.boards)
  end

  test "next_piece" do
    game = games(:game1)
    assert_difference("game.boards.length") do
      game.next_piece
    end
    str = <<EOP
●　
●●
●○
EOP
    pieces = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 2, str)
    expected = Board.new(:player => game.first_player, :position => 2, :players_context => {}, :pieces => pieces)
    assert_board_equal(expected, game.boards.last)

    assert_difference("game.boards.length") do
      game.next_piece
    end
    str = <<EOP
○●　
　○●
　●○
EOP
    pieces = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 2, game.board_width / 2 - 2, str)
    expected = Board.new(:player => game.second_player, :position => 3, :players_context => {}, :pieces => pieces)
    assert_board_equal(expected, game.boards.last)

    assert_difference("game.boards.length") do
      game.next_piece
    end
    str = <<EOP
●●●　
　　○●
　　●○
EOP
    pieces = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 3, game.board_width / 2 - 2, str)
    expected = Board.new(:player => game.first_player, :position => 4, :players_context => {}, :pieces => pieces)
    assert_board_equal(expected, game.boards.last)
  end

  test "next_piece:プレイヤーのコンテキストを格納する" do
    game = games(:game1)
    game.first_player = players(:player3)
    assert_difference("game.boards.length") do
      game.next_piece
    end
    expected = {
      "data1" => "player's context data",
      "data2" => [1, 2, 3],
    }
    game.reload
    assert_equal(expected, game.boards.last.players_context)
  end
  
  private

  def assert_board_equal(expected, actual)
    assert_equal(expected.position, actual.position)
    assert_equal(expected.player, actual.player)
    if expected.player
      assert_equal(expected.players_context, actual.players_context)
    end
    assert_set_equal(expected.pieces, actual.pieces)
  end

  def assert_boards_equal(expecteds, actuals)
    expecteds.each_with_index do |expected, index|
      assert_board_equal(expected, actuals[index])
    end
    assert_equal(expecteds.length, actuals.length)
  end
end

class Game
  class ContextTest < ActiveSupport::TestCase
    def setup
      game = games(:game1)
      last_board = game.boards.last
      player = game.first_player
      @context = Context.new(game, player, last_board.pieces, last_board.candidates(player))
    end
    
    test "Context.new" do
      expected_pieces = Array.new(@context.game.board_width) { |i| Array.new(@context.game.board_height) }
      @context.game.boards.last.pieces.each do |x, y, player_id|
        expected_pieces[x][y] = (@context.player.id == player_id)
      end
      assert_equal(expected_pieces, @context.pieces)
    end
    
    test "count_changed_pieces" do
      game = @context.game
      game.board_width = 7
      game.board_height = 7
      pieces = string_to_pieces_matrix(game, @context.player, 0, 0, PIECES_PATTERN_1)
      args_expecteds = [
                        # 自分の手
                        [[true, 3, 3], 8],
                        [[true, 0, 0], 0],
                        
                        # 相手の手
                        [[false, 0, 0], 1],
                        [[false, 2, 0], 2],
                        [[false, 3, 3], 0],
                       ]
      args_expecteds.each_with_index do |args_expected, i|
        player_flag, x, y = *args_expected[0]
        assert_equal(args_expected[1], @context.count_changed_pieces(player_flag, pieces, x, y),
                     "i=< #{i}> player=<#{player_flag}> x=<#{x}> y=<#{y}>")
      end
    end

    test "changed_pieces" do
      game = @context.game
      game.board_width = 7
      game.board_height = 7
      pieces = string_to_pieces_matrix(game, @context.player, 0, 0, PIECES_PATTERN_1)
      args_expecteds = [
                        # 自分の手
                        [[true, 3, 3], [[2, 2], [3, 2], [4, 2], [2, 3], [4, 3], [2, 4], [3, 4], [4, 4]]],
                        [[true, 0, 0], []],

                        # 相手の手
                        [[false, 0, 0], [[1, 1]]],
                        [[false, 2, 0], [[2, 1], [3, 1]]],
                        [[false, 3, 3], []],
                       ]
      args_expecteds.each_with_index do |args_expected, i|
        player_flag, x, y = *args_expected[0]
        assert_set_equal(args_expected[1], @context.changed_pieces(player_flag, pieces, x, y),
                         "i=< #{i}> player=<#{player_flag}> x=<#{x}> y=<#{y}>")
      end
    end

    test "next_candidates" do
      game = @context.game
      game.board_width = 7
      game.board_height = 7
      pieces = string_to_pieces_matrix(game, @context.player, 0, 0, PIECES_PATTERN_1)
      expected = [[3, 3]]
      assert_set_equal(expected, @context.next_candidates(true, pieces))
      expected = [
                  [0, 0],
                  [0, 1],
                  [0, 2],
                  [0, 3],
                  [0, 4],
                  [0, 5],
                  [0, 6],
                  [1, 0],
                  [2, 0],
                  [3, 0],
                  [4, 0],
                  [5, 0],
                  [6, 0],
                  [1, 6],
                  [2, 6],
                  [3, 6],
                  [4, 6],
                  [5, 6],
                  [6, 1],
                  [6, 2],
                  [6, 3],
                  [6, 4],
                  [6, 5],
                  [6, 6],
                ]
      assert_set_equal(expected, @context.next_candidates(false, pieces))
    end

    private

    # 文字列からpiecesの配列を生成する。
    def string_to_pieces_matrix(game, player, left, top, str)
      pieces = Array.new(game.board_width) { |i| Array.new(game.board_height) }
      string_to_pieces(game.first_player, game.second_player, left, top, str).each do |x, y, player_id|
        pieces[x][y] = (player.id == player_id)
      end
      return pieces
    end

    # 駒のパターン1
    PIECES_PATTERN_1 = <<EOP
　　　　　　　
　●●●●●　
　●○○○●　
　●○　○●　
　●○○○●　
　●●●●●　
　　　　　　　
EOP
  end
end
