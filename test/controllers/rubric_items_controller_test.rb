require 'test_helper'

class RubricItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rubric_item = rubric_items(:one)
  end

  test "should get index" do
    get rubric_items_url
    assert_response :success
  end

  test "should get new" do
    get new_rubric_item_url
    assert_response :success
  end

  test "should create rubric_item" do
    assert_difference('RubricItem.count') do
      post rubric_items_url, params: { rubric_item: { location: @rubric_item.location, points: @rubric_item.points, problem_id: @rubric_item.problem_id, title: @rubric_item.title } }
    end

    assert_redirected_to rubric_item_url(RubricItem.last)
  end

  test "should show rubric_item" do
    get rubric_item_url(@rubric_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_rubric_item_url(@rubric_item)
    assert_response :success
  end

  test "should update rubric_item" do
    patch rubric_item_url(@rubric_item), params: { rubric_item: { location: @rubric_item.location, points: @rubric_item.points, problem_id: @rubric_item.problem_id, title: @rubric_item.title } }
    assert_redirected_to rubric_item_url(@rubric_item)
  end

  test "should destroy rubric_item" do
    assert_difference('RubricItem.count', -1) do
      delete rubric_item_url(@rubric_item)
    end

    assert_redirected_to rubric_items_url
  end
end
