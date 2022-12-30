class AssignedsController < ApplicationController
  before_action :set_assigned, only: [:edit, :update, :destroy, :adjustments, :grade_settings, :toggle_hide_grades, :bulk_download, :view_bulk_upload, :bulk_upload, :view_bulk_sort, :bulk_sort, :download_bulk_file, :view_bulk_file, :problems, :show_problem, :grade_problem, :toggle_submission_notification, :toggle_regrade_request_notification, :reset_notifications, :clone_all]
  before_action :set_assigned_preload, only: [:gradebook, :gradebook_csv]
  before_action :set_problem, only: [:show_problem, :grade_problem]
  
  before_action :validate_problem_in_assignment!, only: [:show_problem, :grade_problem]
  
  before_action :authenticate_logged_in!
  
  before_action only: [:create] {authenticate_class_admin!(Klass.find(assigned_params[:klass_id])) }
  before_action only: [:edit, :update, :destroy, :adjustments, :grade_settings, :view_bulk_upload, :bulk_upload, :view_bulk_sort, :bulk_sort, :download_bulk_file, :view_bulk_file, :reset_notifications] {authenticate_class_admin!(@assigned.klass) }
  
  before_action only: [:toggle_hide_grades, :bulk_download, :gradebook, :gradebook_csv, :problems, :show_problem, :grade_problem, :toggle_submission_notification, :toggle_regrade_request_notification, :clone_all] {authenticate_assigned_grader!(@assigned)}
  
  before_action :authenticate_bulk_supported, only: [:view_bulk_file, :view_bulk_sort, :view_bulk_upload, :bulk_download, :bulk_sort, :bulk_upload, :download_bulk_file]
  
  require 'zip'
  
  def gradebook
  end
  
  def gradebook_csv
  
    # Column headers
    str = "Contributors, Previous Contributors, "
	str += @assigned.assignment.problems.map{|p| p.title.gsub(",","")+"(/"+p.points.to_s+")"}.join(", ")
	str += ", Overall Adjustment, Percent Modifier, Grade (/"+@assigned.get_adjusted_max_grade.to_s+")\n"
	
	# Get submission list, filtering past submissions if needed
	subs = nil
	if params[:skip_prev]
	  subs = @assigned.submissions.select{|s| s.contributors.any?}
	else
	  subs = @assigned.submissions
	end
	
	# Add data for each submission
	subs.each do |s|
	  str += s.contributors.map{|c| c.user.get_full_name.gsub(",","")}.join(" ") + ","
	  str += s.past_contributors.map{|c| c.user.get_full_name.gsub(",","")}.join(" ") + ","
	  
	  @assigned.assignment.problems.each do |p|
		gp = s.graded_problems.find_by(problem: p)
		if gp && gp.graded?
		  str+=gp.get_grade_points.to_s+","
		else
		  str+=","
		end
	  end
	  
	  str += s.point_adjustment.to_s + ", "
	  str += s.percent_modifier.round(2).to_s + ", "
	  if s.graded?
	    str += s.get_adjusted_grade_points.to_s
	  end
	  str += "\n"
	  
	end
  
    filename = @assigned.assignment.title + "_"
	if @assigned.klass.course
	  filename += @assigned.klass.course.course_code + "_"
	end
	filename += @assigned.klass.semester + "_" + @assigned.klass.section.to_s + "_" + DateTime.current.to_s(:short) + ".csv"
	
    send_data str, filename: filename, disposition: "download"
  end
  
  def problems
    @problems = @assigned.assignment.problems
  end

  def show_problem
    @submissions = Submission.where(assigned: @assigned)
  end

  def grade_problem
    @submissions = Submission.where(assigned: @assigned)
	
	params[:Submissions].each do |sid, s|
	  #Silently ignore submissions that aren't actually part of this assigned assignment
	  submission = Submission.find(sid)
	  if @submissions.include?(submission)
	    
		graded_problem = submission.graded_problems.find_by(problem: @problem)
		
		unless graded_problem
		  graded_problem = GradedProblem.new(submission: submission, problem: @problem)
		  graded_problem.save!
		end

		graded_problem.with_lock do
		  checkboxes = s[:checkboxes]
		  dirty = false
		  if checkboxes
		    checkboxes.each do | item_id, value |
		      if graded_problem.checked_rubric_items.find_by(rubric_item_id: item_id)
			    if value=="1"
			      # Already checked, do nothing
			    else
			      # Box unchecked, delete entry
			      graded_problem.checked_rubric_items.find_by(rubric_item_id: item_id).destroy!
				  dirty = true
			    end
		      else
			    if value=="1"
			      # Box checked, add database entry
			      i = CheckedRubricItem.new(rubric_item_id: item_id, graded_problem: graded_problem)
			      i.save!
				  dirty = true
			    else
			      # Leave box unchecked, do nothing
			    end
		      end
		    end
		  end
		  
		  #Save changed comments or adjustment if necessary
		  graded_problem.point_adjustment = s[:point_adjustment]
		  graded_problem.comments = s[:comments]
		  
		  if dirty || graded_problem.comments_changed? || graded_problem.point_adjustment_changed?
		    graded_problem.grader_id = current_user.id
		    graded_problem.save!
		  end
		  
		end
	  end
    end
	
	# Redirect based on which button was pressed
	next_prob = nil
	case params[:commit]
	  when "Next Problem"
		next_prob = @assigned.assignment.problems.find_by(location: @problem.location+1)
		
	  when "Previous Problem"
		next_prob = @assigned.assignment.problems.find_by(location: @problem.location-1)
		
	  when "Save"
	    next_prob = @problem
	end
	
	if next_prob
	  redirect_to assignment_show_grade_problem_path(@assigned.assignment, @assigned, problem_id: next_prob.id), notice: "Changes saved."
	else
	   redirect_to assignment_show_grade_problem_path(@assigned.assignment, @assigned, problem_id: @problem.id), notice: "Changes saved, reached last problem."
	end
		
  end  
  
  # GET /assigneds/new
  def new
    @assigned = Assigned.new
	@assigned.max_contributors = 1
	@assigned.assignment_id = params[:assignment_id]
	if params[:class]
	  @assigned.klass_id = params[:class]
	else
	  # No class, redirect_to
	  redirect_to root_url
	end
  end

  # GET /assignments/:id/assigned/:id
  def edit
  end

  # GET /assignments/:id/assigned/:id/grade_settings
  def grade_settings
  end
  
  # PATCH assignment/:id/assigned/:id/adjustments
  def adjustments
    if @assigned.update(params.require(:assigned).permit(:max_points_override, :point_value_scale))
	  redirect_to submissions_path(assigned: @assigned), notice: "Updated grading adjustments."
	else
	  redirect_to submissions_path(assigned: @assigned), alert: "Failed to update adjustments: "+@assigned.errors.full_messages.join(", ")
	end
  end
  
  # POST assignment/:id/assign
  def create
    @assigned = Assigned.new(assigned_params)
	
	r = nil
	if @assigned.assignment.student_file? || @assigned.assignment.professor_file?
	  r = Repo.new
	  @assigned.repo = r
	end
	
    respond_to do |format|
      if @assigned.save
	    if r
		  r.init_submissions_repository
		end
		
		# Create blank submissions if grade only type
		if @assigned.assignment.grade_only?
		  @assigned.klass.students.each do |stu|
		    s = Submission.new(blank: true, assigned: @assigned)
			s.turned_in_time = DateTime.current
			s.save!
			Contributor.create!(user: stu.user, submission: s)
		  end
		end
		
        format.html { redirect_to klass_assignments_path(@assigned.klass_id), notice: 'Assignment has been assigned!' }
        format.json { render :show, status: :created, location: @assigned }
      else
	    if r
	      r.destroy
		end
        format.html { redirect_to assignment_assign_path(@assigned.assignment, class: params[:class]), alert: 'Failed to assign assignment: '+@assigned.errors.full_messages.join(", ") }
        format.json { render json: @assigned.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT assignment/:id/assigned/:id
  def update
    edit_params =  params.require(:assigned).permit(:due_date, :allow_late_submissions, :max_contributors, :allow_resubmissions, :limit_resubmissions, :resubmission_limit)

    respond_to do |format|
      if @assigned.update(assigned_params)
        format.html { redirect_to assignment_assigned_path(@assigned.assignment,@assigned), notice: 'Assigned assignment successfully updated.' }
        format.json { render :show, status: :ok, location: @assigned }
      else
		format.html {redirect_to assignment_assigned_path(@assigned.assignment,@assigned), alert: 'Failed to update assigned details: '+@assigned.errors.full_messages.join(", ")}
        format.json { render json: @assigned.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE assignments/:id/unassign/:id
  def destroy
    @assigned.destroy
    respond_to do |format|
      format.html { redirect_to klass_assignments_path(@assigned.klass), notice: 'Assignment unassigned.' }
      format.json { head :no_content }
    end
  end
  
  def toggle_hide_grades
	@assigned.toggle(:hide_grades).save!
	
	if !@assigned.hide_grades
	  @assigned.submissions.each do |s|
	    s.notify_if_graded
	  end
	end
	
	redirect_to submissions_path(assigned: @assigned), notice: (@assigned.hide_grades ? "Grades and feedback now hidden from students. Assignment no longer counts towards grades." : "Grades and feedback unhidden. Assignment now counts towards grades.")
  end

  def reset_notifications
    @assigned.submissions.each do |s|
	  s.update_column(:notified_graded, false)
	  
	  s.contributors.each do |c|
	    c.update_column(:feedback_seen, false)
	  end
	  
	  s.notify_if_graded
	end
	
	redirect_to assignment_grade_settings_path(@assigned.assignment, @assigned), notice: "Graded notifications reset."
  end

  def bulk_download
    # Zip submissions repository in memory and send
	
	zstream = NIL
	  
	@assigned.repo.with_lock do
	  zstream = Zip::OutputStream.write_buffer do |z|
		  
		rdir = @assigned.repo.get_repository_read_directory
		  
		# Zip each file in repo
		Dir.foreach(rdir) do |f|
		  unless f[0]=='.' || File.directory?(rdir+File::SEPARATOR+f)
			z.put_next_entry(f)
			z.print(File.read(rdir+File::SEPARATOR+f))
		  end
		end
		  
	  end
	end
	  
	# Reset stream to beginning so it can be read
	zstream.rewind
	  
	send_data zstream.read, filename: "submissions-"+@assigned.id.to_s+".zip"
  end
  
  def view_bulk_upload
    # Page with bulk upload
  end
  
  def bulk_upload
    # Place each file uploaded into unsorted directory of submissions list
	@assigned.repo.bulk_upload(params[:files],
	  current_user.get_full_real_name+ " ("+current_user.id.to_s+") uploaded in bulk on "  +DateTime.current.to_s
	)
	
	redirect_to assignment_bulk_sort_path, notice: "Files uploaded. They will need to be assigned to students before they can be graded."
  end
  
  def view_bulk_sort
    # View sorting page
  end
  
  def bulk_sort
    @assigned.with_lock do
    # Sort files based on user input
	
	# Gets hash parameter files, key is filename, value is:
	# >0: user ID
	# -1: Unsorted (ignore this file)
	# -2: Delete this file
	
	# Make sure all ids are of students
	params[:files].each do |f, op|
	  if op.to_i > 0
	    unless User.find(op.to_i) && User.find(op.to_i).get_student_classes().include?(@assigned.klass)
		  redirect_to assignment_view_bulk_sort_path(@assigned), alert: "Selected student is not part of this class!"
		  return
		end
	  end
	end
	
	# Make sure nobody got selected twice
	# used = []
	# params[:files].each do |f, op|
	  # if(op.to_i>0)
	    # if(used.include?(op.to_i))
		  # #User is selected more than once
		  # redirect_to assignment_view_bulk_sort_path(@assigned), alert: "A user was selected for more than one file, please try again."
		  # return
		# end
		
		# unless(User.find(op.to_i).get_student_classes().include?(@assigned.klass) || @assigned.get_user_submission(u))
		  # #User is selected more than once
		  # redirect_to assignment_view_bulk_sort_path(@assigned), alert: "Selected student already has a submission or isn't in this class!"
		  # return
		# end
		
		# used.push(op.to_i)
	  # end
	# end
	
	# Do sorting
	@assigned.repo.bulk_sort(params[:files],
	current_user.get_full_real_name+ " ("+current_user.id.to_s+") sorted bulk uploads.",
	params[:is_feedback]=="1", @assigned)
	
	redirect_to assignment_view_bulk_sort_path(@assigned), notice: "Files sorted and submissions created."
	
	end
  end
  
  def download_bulk_file
    # View file in unsorted directory
	
	path = @assigned.repo.get_repository_read_directory + File::SEPARATOR + "unsorted" + File::SEPARATOR + params[:file]
    if @assigned.repo.is_safe_directory?([params[:file]]) && File.exist?(path)
	  
	  f = File.open(path,"rb")
	  send_data f.read, filename: params[:file], disposition: 'attachment'
	  f.close()
	  
	else
	  redirect_to (root_url), alert: "Failed to download file."
	end
  end
  
  def view_bulk_file
    # View file in unsorted directory
	
	path = @assigned.repo.get_repository_read_directory + File::SEPARATOR + "unsorted" + File::SEPARATOR + params[:file]
    if @assigned.repo.is_safe_directory?([params[:file]]) && File.exist?(path)
	  
	  f = File.open(path,"rb")
	  send_data f.read, filename: params[:file], disposition: 'inline'
	  f.close()
	  
	else
	  redirect_to (root_url), alert: "Failed to download file."
	end
  end
  
  
  def toggle_submission_notification
    # Check if user is currently notified for this assigned
	n = NotifyGraderNewSubmission.find_by(assigned: @assigned, user: current_user)
	
	if n
	  n.destroy!
	  redirect_to params[:return_url], notice: "Notifications disabled!"
	else
	  NotifyGraderNewSubmission.create!(assigned: @assigned, user: current_user)
	  redirect_to params[:return_url], notice: "Notifications enabled!"
	end
	
  end
  
  
  def toggle_regrade_request_notification
    # Check if user is currently notified for this assigned
	n = NotifyGraderRegradeRequest.find_by(assigned: @assigned, user: current_user)
	
	if n
	  n.destroy!
	  redirect_to params[:return_url], notice: "Notifications disabled!"
	else
	  NotifyGraderRegradeRequest.create!(assigned: @assigned, user: current_user)
	  redirect_to params[:return_url], notice: "Notifications enabled!"
	end
	
  end
  
  
  def clone_all
    if @assigned.assignment.student_repo?
	  # Generate a script to clone all repositories
	  submissions = @assigned.submissions.where.not(repo: nil)
	  submissions = submissions.select{|s| s.repo}
	  
	  unless params[:include_prev]
	    submissions = submissions.select{|s| s.contributors.any?}
	  end
	  
	  unless params[:include_incomplete]
	    submissions = submissions.select{|s| s.turned_in?}
	  end
	  
	  reps = submissions.map{|s| s.repo_id.to_s}
	  
	  str = "for repo in "+reps.join(" ")
	  str += "\ndo\n"
	  str += "git clone git@"+request.base_url.gsub("http://","").gsub("https://","")+":r$repo"
	  str += "\ndone"
	  
	  response.headers["X-Download_Options"] = ""
	  
	  send_data str, filename: "clone-all"+@assigned.id.to_s+".sh", disposition: 'attachment'	  
	  
	end
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assigned
      @assigned = Assigned.find(params[:id])
    end
	
	def set_assigned_preload
	  @assigned = Assigned.where(id: params[:id]).includes([
	    submissions: [
		  contributors: [:user],
		  past_contributors: [:user],
		  graded_problems: [
		    problem: [
			  :rubric_items
			],
		    checked_rubric_items: [:rubric_item]
		  ]
		],
		assignment: [
		  problems: [
			:rubric_items
		  ]
		]
	  ]).first
	end

	def set_problem
	  @problem = Problem.find(params[:problem_id])
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assigned_params
      params.require(:assigned).permit(:assignment_id, :klass_id, :due_date, :allow_late_submissions, :max_contributors, :allow_resubmissions, :limit_resubmissions, :resubmission_limit)
    end
	
	def authenticate_bulk_supported
	  unless @assigned.assignment.student_file? || @assigned.assignment.professor_file?
        redirect_to root_url, alert: "Bulk operations not supported for this assignment."
	  end
	end
	
	def validate_problem_in_assignment!
	  unless @assigned.assignment.problems.include?(@problem)
	    redirect_to root_url
	  end
	end
end
