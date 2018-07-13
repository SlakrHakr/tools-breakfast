require 'test_helper'

class PeopleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get people_index_url
    assert_response :success
  end

  test "should get create" do
    get people_create_url
    assert_response :success
  end

  test "should get update" do
    get people_update_url
    assert_response :success
  end

  test "should get destroy" do
    get people_destroy_url
    assert_response :success
  end

end
