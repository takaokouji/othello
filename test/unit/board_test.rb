require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  test "Board.new_initial_board:初期状態のBoardを生成する。" do
    game = games(:game1)
    board = Board.new_initial_board(game)
    assert_equal(1, board.position)
    assert_equal(nil, board.player)
    expected = [
                [game.board_width / 2, game.board_height / 2 - 1, game.first_player_id],
                [game.board_width / 2 - 1, game.board_height / 2, game.first_player_id],
                [game.board_width / 2 - 1, game.board_height / 2 - 1, game.second_player_id],
                [game.board_width / 2, game.board_height / 2, game.second_player_id],
               ]
    assert_set_equal(expected, board.pieces)
  end
end
