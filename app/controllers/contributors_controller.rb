class ContributorsController < ApplicationController
  before_action :set_contributor, only: [:destroy]

  before_action :authenticate_logged_in!
  #before_action :authenticate_can_leave_submission!, only: [:destroy]
  
  before_action only: [:destroy] {authenticate_assigned_grader!(@contributor.submission.assigned)}
  
  before_action :set_submission, only: [:create]
  before_action only: [:create] {authenticate_assigned_grader!(@submission.assigned)}
  
  def create
    # Find user and make sure they are in the class
	u = User.find_by(email: params[:email])
	
	if u
	  if u.get_student_classes.include?(@submission.assigned.klass)
	    Contributor.create!(user: u, submission: @submission)
		
		redirect_to submission_grade_path(@submission), notice: "Contributor added!"
	  else
	    redirect_to submission_grade_path(@submission), alert: "Specified user is not in this class."
	  end
	else
	  redirect_to submission_grade_path(@submission), alert: "Unable to find user with that email."
	end
	
  end
  
  # DELETE /contributors/1
  # DELETE /contributors/1.json
  def destroy
    PastContributor.create(user: @contributor.user, submission: @contributor.submission)
    @contributor.destroy
    respond_to do |format|
      format.html { redirect_to submission_grade_path(@contributor.submission), notice: 'User removed from submission.' }
      format.json { head :no_content }
	  
	  if @contributor.submission.assigned.assignment.student_repo?
	    Repo.refresh_repo_authorizations
	  end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contributor
      @contributor = Contributor.find(params[:id])
    end
	
	def set_submission
	  @submission = Submission.find(params[:submission_id])
	end
	
	

=begin	
	#Can't leave if:
	# - graded
	# - Overdue and cannot resubmit
	# - Not the same user
	def authenticate_can_leave_submission!
	  unless current_user == @contributor.user && !@contributor.submission.graded? && (!@contributor.submission.assigned.overdue? || @contributor.submission.assigned.allow_late_submissions)
	    redirect_to root_url, alert: "Couldn't remove user from submission."
	  end
	end
=end
end
