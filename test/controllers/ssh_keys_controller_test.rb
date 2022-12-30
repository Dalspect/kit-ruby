require 'test_helper'

class SshKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ssh_key = ssh_keys(:one)
  end

  test "should get index" do
    get ssh_keys_url
    assert_response :success
  end

  test "should get new" do
    get new_ssh_key_url
    assert_response :success
  end

  test "should create ssh_key" do
    assert_difference('SshKey.count') do
      post ssh_keys_url, params: { ssh_key: {  } }
    end

    assert_redirected_to ssh_key_url(SshKey.last)
  end

  test "should show ssh_key" do
    get ssh_key_url(@ssh_key)
    assert_response :success
  end

  test "should get edit" do
    get edit_ssh_key_url(@ssh_key)
    assert_response :success
  end

  test "should update ssh_key" do
    patch ssh_key_url(@ssh_key), params: { ssh_key: {  } }
    assert_redirected_to ssh_key_url(@ssh_key)
  end

  test "should destroy ssh_key" do
    assert_difference('SshKey.count', -1) do
      delete ssh_key_url(@ssh_key)
    end

    assert_redirected_to ssh_keys_url
  end
end
