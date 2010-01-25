require 'test_helper'

class PlayersControllerTest < ActionController::TestCase
  def setup
    login_as :quentin
  end
  
  test "should show player" do
    get :show, :id => players(:player1).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => players(:player1).to_param
    assert_response :success
  end

  test "should update player" do
    put :update, :id => players(:player1).to_param, :player => { }
    assert_redirected_to player_path(assigns(:player))
  end
end
