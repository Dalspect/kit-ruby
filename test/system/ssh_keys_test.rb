require "application_system_test_case"

class SshKeysTest < ApplicationSystemTestCase
  setup do
    @ssh_key = ssh_keys(:one)
  end

  test "visiting the index" do
    visit ssh_keys_url
    assert_selector "h1", text: "Ssh Keys"
  end

  test "creating a Ssh key" do
    visit ssh_keys_url
    click_on "New Ssh Key"

    click_on "Create Ssh key"

    assert_text "Ssh key was successfully created"
    click_on "Back"
  end

  test "updating a Ssh key" do
    visit ssh_keys_url
    click_on "Edit", match: :first

    click_on "Update Ssh key"

    assert_text "Ssh key was successfully updated"
    click_on "Back"
  end

  test "destroying a Ssh key" do
    visit ssh_keys_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ssh key was successfully destroyed"
  end
end
