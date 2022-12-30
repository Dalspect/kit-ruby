require 'test_helper'

class AssignedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assigned = assigneds(:one)
  end

  test "should get index" do
    get assigneds_url
    assert_response :success
  end

  test "should get new" do
    get new_assigned_url
    assert_response :success
  end

  test "should create assigned" do
    assert_difference('Assigned.count') do
      post assigneds_url, params: { assigned: { assignment_id: @assigned.assignment_id, due_date: @assigned.due_date, klass_id: @assigned.klass_id } }
    end

    assert_redirected_to assigned_url(Assigned.last)
  end

  test "should show assigned" do
    get assigned_url(@assigned)
    assert_response :success
  end

  test "should get edit" do
    get edit_assigned_url(@assigned)
    assert_response :success
  end

  test "should update assigned" do
    patch assigned_url(@assigned), params: { assigned: { assignment_id: @assigned.assignment_id, due_date: @assigned.due_date, klass_id: @assigned.klass_id } }
    assert_redirected_to assigned_url(@assigned)
  end

  test "should destroy assigned" do
    assert_difference('Assigned.count', -1) do
      delete assigned_url(@assigned)
    end

    assert_redirected_to assigneds_url
  end
end
