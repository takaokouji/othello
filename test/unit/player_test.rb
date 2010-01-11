require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "load_ai:aiに登録されたsolveメソッドを定義する。" do
    player = players(:player1)
    player.load_ai
    assert_equal("method", defined?(player.solve))
  end
end
