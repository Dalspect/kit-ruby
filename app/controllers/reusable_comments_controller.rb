class ReusableCommentsController < ApplicationController
  before_action :set_reusable_comment, only: [:destroy]
  before_action :set_problem, only: [:create]
  
  before_action :authenticate_logged_in!
  
  before_action :authenticate_grader_or_editor!
 
  # POST /assignment/:id/problems/:id/reusable_comments
  def create
    rc = ReusableComment.new(reusable_comment_params)
	rc.problem = @problem
	
	if rc.save
	  render json: rc, status: :created
	else
	  render json: rc.errors, status: :unprocessable_entity
	end
	
  end

  # DELETE assignment/:id/problems/:id/reusable_comments/:id
  def destroy
    @reusable_comment.destroy!
	
	render json: {success: true}, status: :ok
  end

  private
  
  def set_reusable_comment
    @reusable_comment = ReusableComment.find(params[:id])
	@problem = @reusable_comment.problem
  end
  
  
  def set_problem
    @problem = Problem.find(params[:problem_id])
  end
  
  # Make sure this user can edit reusable comments for @problem
  def authenticate_grader_or_editor!
    # Check if user is a grader
	unless @problem.assignment.assigned.map{|ad| ad.can_grade?(current_user)}.include?(true)
	  # Not allowed to grade any instance of this assigned assignment
	  # Does this user have permission to edit this assignment?
	  unless @problem.assignment.can_edit?(current_user)
	    # Not a grader and can't edit the assignment, begone!
		redirect_to root_url
	  end
	end
  end
  
  def reusable_comment_params
    params.require(:reusable_comment).permit(:comment)
  end
  
end
