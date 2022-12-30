require 'test_helper'

class GradedProblemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @graded_problem = graded_problems(:one)
  end

  test "should get index" do
    get graded_problems_url
    assert_response :success
  end

  test "should get new" do
    get new_graded_problem_url
    assert_response :success
  end

  test "should create graded_problem" do
    assert_difference('GradedProblem.count') do
      post graded_problems_url, params: { graded_problem: { comments: @graded_problem.comments, grader_id: @graded_problem.grader_id, point_adjustment: @graded_problem.point_adjustment, problem_id: @graded_problem.problem_id, submission_id: @graded_problem.submission_id } }
    end

    assert_redirected_to graded_problem_url(GradedProblem.last)
  end

  test "should show graded_problem" do
    get graded_problem_url(@graded_problem)
    assert_response :success
  end

  test "should get edit" do
    get edit_graded_problem_url(@graded_problem)
    assert_response :success
  end

  test "should update graded_problem" do
    patch graded_problem_url(@graded_problem), params: { graded_problem: { comments: @graded_problem.comments, grader_id: @graded_problem.grader_id, point_adjustment: @graded_problem.point_adjustment, problem_id: @graded_problem.problem_id, submission_id: @graded_problem.submission_id } }
    assert_redirected_to graded_problem_url(@graded_problem)
  end

  test "should destroy graded_problem" do
    assert_difference('GradedProblem.count', -1) do
      delete graded_problem_url(@graded_problem)
    end

    assert_redirected_to graded_problems_url
  end
end
