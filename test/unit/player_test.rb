require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "load_ai:aiに登録されたsolveメソッドを定義する。" do
    player = players(:player1)
    player.load_ai
    assert_equal("method", defined?(player.solve))
  end

  test "solveが定義されていない場合、solveメソッドを呼び出したタイミングでsolveメソッドを定義する。" do
    player = players(:player1)
    assert_equal(nil, defined?(player.solve))
    assert_raise(ArgumentError) do
      player.solve
    end
    assert_equal("method", defined?(player.solve))
  end
end
