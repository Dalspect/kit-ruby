require 'test_helper'

class ContributorInvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contributor_invite = contributor_invites(:one)
  end

  test "should get index" do
    get contributor_invites_url
    assert_response :success
  end

  test "should get new" do
    get new_contributor_invite_url
    assert_response :success
  end

  test "should create contributor_invite" do
    assert_difference('ContributorInvite.count') do
      post contributor_invites_url, params: { contributor_invite: { submission_id: @contributor_invite.submission_id, user_id: @contributor_invite.user_id } }
    end

    assert_redirected_to contributor_invite_url(ContributorInvite.last)
  end

  test "should show contributor_invite" do
    get contributor_invite_url(@contributor_invite)
    assert_response :success
  end

  test "should get edit" do
    get edit_contributor_invite_url(@contributor_invite)
    assert_response :success
  end

  test "should update contributor_invite" do
    patch contributor_invite_url(@contributor_invite), params: { contributor_invite: { submission_id: @contributor_invite.submission_id, user_id: @contributor_invite.user_id } }
    assert_redirected_to contributor_invite_url(@contributor_invite)
  end

  test "should destroy contributor_invite" do
    assert_difference('ContributorInvite.count', -1) do
      delete contributor_invite_url(@contributor_invite)
    end

    assert_redirected_to contributor_invites_url
  end
end
