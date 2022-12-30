class GradedProblemsController < ApplicationController
  
  before_action :authenticate_logged_in!
  
  before_action :set_graded_problem, only: [:edit, :update]
  
  before_action :set_submission, only: [:index, :create]
  
  before_action {authenticate_assigned_grader!(@submission.assigned)}
  
  # GET /graded_problems
  # GET /graded_problems.json
  def index
    @graded_problems = @submission.graded_problems
  end

  # GET /graded_problems/1/edit
  def edit
  end

  # POST /graded_problems
  # POST /graded_problems.json
  def create
    @graded_problem = GradedProblem.new
	@graded_problem.submission = @submission
	@graded_problem.problem = Problem.find(params[:problem])

    respond_to do |format|
      if @graded_problem.save
        format.html { redirect_to edit_submission_graded_problem_path(@graded_problem.submission,@graded_problem) }
        format.json { render :show, status: :created, location: @graded_problem }
      else
        format.html { redirect_to root_url, alert: "Couldn't grade problem: "+@graded_problem.errors.full_messages.join(", ") }
        format.json { render json: @graded_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /graded_problems/1
  # PATCH/PUT /graded_problems/1.json
  def update
    # Acquire pessimistic lock on this graded problem
	# This will prevent point calculation and overlapping graders until save is called
	@graded_problem.lock!
	
    # Update checked_rubric_items
	if checkboxes
	checkboxes.each do | item_id, value |
	  if @graded_problem.checked_rubric_items.find_by(rubric_item_id: item_id)
	    if value=="1"
		  # Already checked, do nothing
		else
		  # Box unchecked, delete entry
		  @graded_problem.checked_rubric_items.find_by(rubric_item_id: item_id).destroy
		end
	  else
	    if value=="1"
		  # Box checked, add database entry
		  i = CheckedRubricItem.new(rubric_item_id: item_id, graded_problem: @graded_problem)
		  i.save
		else
		  # Leave box unchecked, do nothing
		end
	  end
	end
	end
	
	@graded_problem.grader_id = current_user.id
	@graded_problem.comments = graded_problem_params[:comments]
	@graded_problem.point_adjustment = graded_problem_params[:point_adjustment]
	
    if @graded_problem.save
      #Redirect based on commit
	  
	  next_prob = nil
	  next_subm = nil
	  
	  notice = nil
	  
	  #problems = @graded_problem.problem.assignment.problems
	  
	  #Change where we redirect based on which button was pushed
	  case params[:commit]
	  when "Next Problem"
		next_prob = get_next_problem
		if next_prob
		  #Next problem exists
		  next_subm = @graded_problem.submission
		else
		  #Go to first problem of next submission
		  next_prob = @graded_problem.problem.assignment.problems.order(location: :asc).first
		  next_subm = get_next_submission
		  notice = "End of submission, starting next"
		  unless next_subm
		    #Out of submissions too
			redirect_to submissions_path(assigned: @submission.assigned), notice: "Last problem of last submission reached!"
		  end
		end
		
		
	  when "Previous Problem"
		next_prob = get_previous_problem
	    if next_prob
		  #Another problem exists
		  next_subm = @graded_problem.submission
		else
		  #This was the first problem
		  #Go to previous problem of last submission
		  next_prob = @graded_problem.problem.assignment.problems.order(location: :asc).last
		  next_subm = get_previous_submission
		  notice = "Beginning of submission reached, now grading previous submission"
		  unless next_subm
		    #Out of submissions too
			redirect_to submissions_path(assigned: @submission.assigned), notice: "First problem and submission reached."
		  end
		end
		
	  when "Next Submission"
	    #Find next submission
		
		next_subm = get_next_submission
		if next_subm
		  #Go to same problem of next submission
		  next_prob = @graded_problem.problem
		else
		  #Out of submissions
		  #Go on to the next problem, starting at first submission
		  next_subm = @graded_problem.submission.assigned.submissions.order(id: :asc).select{|s| s.contributors.any?}.first
		  next_prob = get_next_problem
		  notice = "Ran out of submissions, switching to next problem"
		  unless next_prob
		    #Out of problems too!
			redirect_to submissions_path(assigned: @submission.assigned), notice: "Last problem of last submission reached!"
		  end
		end
		
	  when "Previous Submission"
	   next_subm = get_previous_submission
		if next_subm
		  #Go to same problem of next submission
		  next_prob = @graded_problem.problem
		else
		  #Out of submissions
		  #Go to last submission's previous problem
		  next_subm = @graded_problem.submission.assigned.submissions.order(id: :asc).select{|s| s.contributors.any?}.last
		  next_prob = get_previous_problem
		  notice = "Ran out of submissions, switching to previous problem"
		  unless next_prob
			#Out of problems
			redirect_to submissions_path(assigned: @submission.assigned), notice: "First problem of first submission reached."
		  end
		end
		
	  when "Save"	
	    redirect_to edit_submission_graded_problem_path(@submission, @graded_problem), notice: "Changes saved."
	  end
	  
	  if next_subm && next_prob
	    redirect_to edit_submission_graded_problem_path(next_subm,get_or_generate_graded_problem(next_subm,next_prob)), notice: notice
	  end
	  
    else
      redirect_to edit_submission_graded_problem_path(@graded_problem.submission,@graded_problem), alert: "Unable to grade problem: " + @graded_problem.errors.full_messages.join(", ")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_graded_problem
      @graded_problem = GradedProblem.find(params[:id])
	  @submission = @graded_problem.submission
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def graded_problem_params
      params.require(:graded_problem).permit(:comments, :point_adjustment)
    end
	
	def checkboxes
	  params[:graded_problem][:rubric_items]
	end
	
	def set_submission
	  unless @submission = Submission.find(params[:submission_id])
	    redirect_to root_url
	  end
	end
	
	# Gets graded_problem for problem and submission, generating one if it doesn't exists
	def get_or_generate_graded_problem(submission,problem)
	  if submission.graded_problems.find_by(problem: problem)
	    #Graded problem already created, use it
		return submission.graded_problems.find_by(problem: problem)
	  else
	    #Graded problem not yet created, make a new one
		new_prob = GradedProblem.new(problem: problem, submission: submission)
		new_prob.save
		return new_prob
	  end
	end
	
	# Get the submission after this one
	# nil if none remain
	def get_next_submission
	  return get_next_submission_from(@graded_problem.submission)
	end
	
	#Get submission before this one
	#nil if none remain
	def get_previous_submission
	  return get_previous_submission_from(@graded_problem.submission)
	end
	
	#Get next problem
	#nil if none remain
	def get_next_problem
	  @graded_problem.problem.assignment.problems.find_by(location: (@graded_problem.problem.location+1))
	end
	
	#Get previous problem
	#nil in none remain
	def get_previous_problem
	  @graded_problem.problem.assignment.problems.find_by(location: (@graded_problem.problem.location-1))
	end
end
