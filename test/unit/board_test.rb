require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  test "Board.new_initial_board" do
    game = games(:game1)
    board = Board.new_initial_board(game)
    assert_equal(1, board.position)
    assert_equal(nil, board.player)
    str = <<EOP
○●
●○
EOP
    expected = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 1, str)
    assert_set_equal(expected, board.pieces)
  end

  test "candidates" do
    game = games(:game1)
    expecteds =
      [
       [game.first_player, game.board_width / 2 - 2, game.board_width / 2 - 2, <<EOP,

　○●
　●○

EOP
        <<EOC],
　！
！○●
　●○！
　　！
EOC
       [game.second_player, game.board_width / 2 - 2, game.board_width / 2 - 2, <<EOP,
　●　
　●●
　●○
EOP
        <<EOC],
！●！
　●●
！●○
EOC
       [game.first_player, game.board_width / 2 - 3, game.board_width / 2 - 2, <<EOP,
　○●
　　○●
　　●○
EOP
        <<EOC],
！○●
　！○●
　　●○！
　　　！
EOC
      ]
    expecteds.each do |player, left, top, pieces_str, candidates_str|
      pieces = string_to_pieces(game.first_player, game.second_player, left, top, pieces_str)
      board = Board.new(:game => game, :pieces => pieces)
      expected = string_to_candidates(left, top, candidates_str)
      candidates = board.candidates(player)
      assert_equal(expected, candidates)
    end
  end

  test "changed_pieces" do
    game = games(:game1)
    str = <<EOP
○●
●○
EOP
    pieces = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 1, str)
    board = Board.new(:game => game, :pieces => pieces)

    changed_pieces = board.changed_pieces(game.first_player, game.board_width / 2 - 1, game.board_width / 2 - 2)
    expected = [[game.board_width / 2 - 1, game.board_width / 2 - 1]]
    assert_set_equal(expected, changed_pieces)

    changed_pieces = board.changed_pieces(game.first_player, game.board_width / 2 - 2, game.board_width / 2 - 1)
    expected = [[game.board_width / 2 - 1, game.board_width / 2 - 1]]
    assert_set_equal(expected, changed_pieces)

    changed_pieces = board.changed_pieces(game.first_player, game.board_width / 2 + 1, game.board_width / 2)
    expected = [[game.board_width / 2, game.board_width / 2]]
    assert_set_equal(expected, changed_pieces)

    changed_pieces = board.changed_pieces(game.first_player, game.board_width / 2, game.board_width / 2 + 1)
    expected = [[game.board_width / 2, game.board_width / 2]]
    assert_set_equal(expected, changed_pieces)
  end

  test "set_piece" do
    game = games(:game1)
    str = <<EOP
○●
●○
EOP
    pieces = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 1, str)
    board = Board.new(:game => game, :pieces => pieces)
    pieces = board.set_piece(game.first_player, game.board_width / 2 - 1, game.board_width / 2 - 2)
    str = <<EOP
●
●●
●○
EOP
    expected = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 2, str)
    assert_set_equal(expected, pieces)

    pieces = board.set_piece(game.first_player, game.board_width / 2 - 2, game.board_width / 2 - 1)
    str = <<EOP
●●●
　●○
EOP
    expected = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 2, game.board_width / 2 - 1, str)
    assert_set_equal(expected, pieces)

    pieces = board.set_piece(game.first_player, game.board_width / 2 + 1, game.board_width / 2)
    str = <<EOP
○●
●●●
EOP
    expected = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 1, str)
    assert_set_equal(expected, pieces)

    pieces = board.set_piece(game.first_player, game.board_width / 2, game.board_width / 2 + 1)
    str = <<EOP
○●
●●
　●
EOP
    expected = string_to_pieces(game.first_player, game.second_player, game.board_width / 2 - 1, game.board_width / 2 - 1, str)
    assert_set_equal(expected, pieces)
  end

  private

  # 文字列からcandidatesの配列を生成する。
  def string_to_candidates(left, top, str)
    candidates = []
    x = left
    y = top
    str.scan(/./m) do |c|
      case c
      when "！"
        candidates << [x, y]
        x += 1
      when "\n"
        x = left
        y += 1
      else
        x += 1
      end
    end
    return candidates
  end
end
