require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

=begin
  test "should create game" do
    assert_difference('Game.count') do
      post :create, :game => { }
    end

    assert_redirected_to game_path(assigns(:game))
  end
=end

  test "should show game" do
    get :show, :id => games(:game1).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => games(:game1).to_param
    assert_response :success
  end

  test "should update game" do
    put :update, :id => games(:game1).to_param, :game => { }
    assert_redirected_to game_path(assigns(:game))
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete :destroy, :id => games(:game1).to_param
    end

    assert_redirected_to games_path
  end
end
