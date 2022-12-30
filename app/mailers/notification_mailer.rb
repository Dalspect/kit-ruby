class NotificationMailer < ApplicationMailer
  
  # Student notifications
  # ----------------------
  
  def assignment_assigned(user, assigned)
    @assigned = assigned
	@user = user
	
	mail(to: user.email, subject: 'Kit: New Assignment: '+@assigned.assignment.title)
  end
  
  def submission_graded(user, submission)
    @submission = submission
	@user = user
	
	mail(to: user.email, subject: 'Kit: '+@submission.assigned.assignment.title+' graded')
  end
  
  def contributor_invite(user, submission)
    @submission = submission
	@user = user
	
	mail(to: user.email, subject: 'Kit: Invited to collaborate on '+@submission.assigned.assignment.title)
  end
  
  def extension_granted(extension)
    @user = extension.user
	@assigned = extension.assigned
	@extension = extension
	
	mail(to: @user.email, subject: 'Kit: Extension granted for '+@assigned.assignment.title)
  end
  
  def regrade_response(user,regrade_request)
    @user = user
	@regrade_request = regrade_request
	
	mail(to: user.email, subject: 'Kit: Regrade Request Closed')
  end
  
  
  # Grader/Prof notifications
  # -----------------------------
  
  def grader_assigned(user, assigned)
    @assigned = assigned
	@user = user
	
	mail(to: user.email, subject: 'Kit: Assigned To Grade '+@assigned.assignment.title)
  end
  
  
  def submitted_to_grader(user, submission)
    @user = user
	@submission = submission
	
	mail(to: user.email, subject: 'Kit:'+
	  @submission.contributors.map{|c| c.user.get_preferred_first_name}.to_sentence +
	  ' submitted for ' + @submission.assigned.assignment.title)
  end
  
  
  def regrade_requested(user, regrade_request)
    @user = user
	@regrade_request = regrade_request
	
	mail(to: user.email, subject: 'Kit: Regrade Requested For '+@regrade_request.submission.assigned.assignment.title+' by '+@regrade_request.requested_by.get_preferred_first_name)
	
  end

end