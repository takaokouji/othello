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

  private

  def assert_boards_equal(expecteds, actuals)
    expecteds.each_with_index do |expected, index|
      board = actuals[index]
      assert_equal(expected.position, board.position)
      assert_equal(expected.player, board.player)
      if expected.player
        assert_equal(expected.players_context, board.players_context)
      end
      assert_set_equal(expected.pieces, board.pieces)
    end
    assert_equal(expecteds.length, actuals.length)
  end
end
