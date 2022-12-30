require 'test_helper'

class AssignedGradersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assigned_grader = assigned_graders(:one)
  end

  test "should get index" do
    get assigned_graders_url
    assert_response :success
  end

  test "should get new" do
    get new_assigned_grader_url
    assert_response :success
  end

  test "should create assigned_grader" do
    assert_difference('AssignedGrader.count') do
      post assigned_graders_url, params: { assigned_grader: { assigned_id: @assigned_grader.assigned_id, user_id: @assigned_grader.user_id } }
    end

    assert_redirected_to assigned_grader_url(AssignedGrader.last)
  end

  test "should show assigned_grader" do
    get assigned_grader_url(@assigned_grader)
    assert_response :success
  end

  test "should get edit" do
    get edit_assigned_grader_url(@assigned_grader)
    assert_response :success
  end

  test "should update assigned_grader" do
    patch assigned_grader_url(@assigned_grader), params: { assigned_grader: { assigned_id: @assigned_grader.assigned_id, user_id: @assigned_grader.user_id } }
    assert_redirected_to assigned_grader_url(@assigned_grader)
  end

  test "should destroy assigned_grader" do
    assert_difference('AssignedGrader.count', -1) do
      delete assigned_grader_url(@assigned_grader)
    end

    assert_redirected_to assigned_graders_url
  end
end
