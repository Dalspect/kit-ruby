require "application_system_test_case"

class ContributorInvitesTest < ApplicationSystemTestCase
  setup do
    @contributor_invite = contributor_invites(:one)
  end

  test "visiting the index" do
    visit contributor_invites_url
    assert_selector "h1", text: "Contributor Invites"
  end

  test "creating a Contributor invite" do
    visit contributor_invites_url
    click_on "New Contributor Invite"

    fill_in "Submission", with: @contributor_invite.submission_id
    fill_in "User", with: @contributor_invite.user_id
    click_on "Create Contributor invite"

    assert_text "Contributor invite was successfully created"
    click_on "Back"
  end

  test "updating a Contributor invite" do
    visit contributor_invites_url
    click_on "Edit", match: :first

    fill_in "Submission", with: @contributor_invite.submission_id
    fill_in "User", with: @contributor_invite.user_id
    click_on "Update Contributor invite"

    assert_text "Contributor invite was successfully updated"
    click_on "Back"
  end

  test "destroying a Contributor invite" do
    visit contributor_invites_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Contributor invite was successfully destroyed"
  end
end
