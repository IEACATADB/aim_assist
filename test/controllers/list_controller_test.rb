require 'test_helper'

class ListControllerTest < ActionController::TestCase
  test "should get list_items" do
    get :list_items
    assert_response :success
  end

  test "should get list_champions" do
    get :list_champions
    assert_response :success
  end

end
