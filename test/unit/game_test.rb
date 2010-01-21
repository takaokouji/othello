# -*- coding: utf-8 -*-
require 'test_helper'

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
