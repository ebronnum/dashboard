require 'test_helper'

class ScriptsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin = create(:admin)
    sign_in(@admin)

    @not_admin = create(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scripts)
    assert_equal Script.all, assigns(:scripts)
  end

  test "should not get index if not signed in" do
    sign_out @admin
    get :index

    assert_redirected_to_sign_in
  end

  test "should not get index if not admin" do
    sign_in @not_admin

    get :index

    assert_response :forbidden
  end

  test "should get show" do
    sign_in @admin
    get :show, id: Script::FLAPPY_ID
    assert_response :success
  end

  test "should get show if not signed in" do
    sign_out @admin
    get :show, id: Script::FLAPPY_ID
    assert_response :success
  end

  test "should get show if not admin" do
    sign_in @not_admin
    get :show, id: Script::FLAPPY_ID
    assert_response :success
  end

end
