require 'test_helper'

class UserInvitesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get user_invites_create_url
    assert_response :success
  end

  test "should get create_bulk" do
    get user_invites_create_bulk_url
    assert_response :success
  end

  test "should get destroy" do
    get user_invites_destroy_url
    assert_response :success
  end

  test "should get show_accept" do
    get user_invites_show_accept_url
    assert_response :success
  end

  test "should get accept" do
    get user_invites_accept_url
    assert_response :success
  end

  test "should get resend" do
    get user_invites_resend_url
    assert_response :success
  end

end
