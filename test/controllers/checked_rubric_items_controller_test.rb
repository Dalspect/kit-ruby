require 'test_helper'

class CheckedRubricItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @checked_rubric_item = checked_rubric_items(:one)
  end

  test "should get index" do
    get checked_rubric_items_url
    assert_response :success
  end

  test "should get new" do
    get new_checked_rubric_item_url
    assert_response :success
  end

  test "should create checked_rubric_item" do
    assert_difference('CheckedRubricItem.count') do
      post checked_rubric_items_url, params: { checked_rubric_item: { graded_problem_id: @checked_rubric_item.graded_problem_id, rubric_item_id: @checked_rubric_item.rubric_item_id } }
    end

    assert_redirected_to checked_rubric_item_url(CheckedRubricItem.last)
  end

  test "should show checked_rubric_item" do
    get checked_rubric_item_url(@checked_rubric_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_checked_rubric_item_url(@checked_rubric_item)
    assert_response :success
  end

  test "should update checked_rubric_item" do
    patch checked_rubric_item_url(@checked_rubric_item), params: { checked_rubric_item: { graded_problem_id: @checked_rubric_item.graded_problem_id, rubric_item_id: @checked_rubric_item.rubric_item_id } }
    assert_redirected_to checked_rubric_item_url(@checked_rubric_item)
  end

  test "should destroy checked_rubric_item" do
    assert_difference('CheckedRubricItem.count', -1) do
      delete checked_rubric_item_url(@checked_rubric_item)
    end

    assert_redirected_to checked_rubric_items_url
  end
end
