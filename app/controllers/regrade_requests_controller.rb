class RegradeRequestsController < ApplicationController
  before_action :set_regrade_request, only: [:close]
  before_action :set_submission, only: [:create]

  before_action :authenticate_logged_in!
  
  #Authenticate permission to make a request
  before_action :authenticate_contributor!, only: [:create]
  
  #Authenticate permission to close request
  before_action only: [:close] {authenticate_assigned_grader!(@submission.assigned)}
	
  # POST /regrade_request
  def create
    @regrade_request = RegradeRequest.new(request_params)
	@regrade_request.requested_by = current_user
	@regrade_request.submission = @submission
	
    if @regrade_request.save
	  @submission.assigned.notify_graders_regrade_requested(@regrade_request)
      redirect_to submission_path(@submission), notice: 'Regrade requested!'
    else
      redirect_to submission_path(@submission), alert: 'Failed to request regrade: '+@regrade_request.errors.full_messages.join(", ")
    end
  end

  # PATCH /regrade_request/:id/close
  def close
    @regrade_request.closed = true
	@regrade_request.closed_by = current_user
	
    if @regrade_request.update(close_params)
	  
	  @submission.contributors.each do |c|
	    c.update_column(:feedback_seen, false)
	  end
	  
	  @submission.notify_contributors_regrade_response(@regrade_request)
	  
      redirect_to submission_grade_path(@submission), notice: 'Regrade request closed!'
    else
      redirect_to submission_grade_path(@submission), alert: 'Failed to close regrade request: '+@regrade_request.errors.full_messages.join(", ")
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regrade_request
      @regrade_request = RegradeRequest.find(params[:id])
	  @submission = @regrade_request.submission
    end
	
	def set_submission
	  @submission = Submission.find(params[:submission_id])
	end
	
	def authenticate_contributor!
	  unless current_user.contributors.map {|c| c.submission}.include?(@submission)
	    redirect_to root_url
	  end
	end
	
	
	def request_params
      params.permit(:reason)
    end
	
	def close_params
	  params.require(:regrade_request).permit(:response)
	end
end
