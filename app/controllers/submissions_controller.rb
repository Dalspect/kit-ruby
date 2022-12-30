class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :destroy]
  before_action :set_submission_c, only: [:grade, :render_file, :adjustments, :turn_in, :download, :download_inline, :force_turn_in, :un_turn_in, :add_file, :add_url, :reset_notification]
  
  before_action :authenticate_logged_in!
  before_action :authenticate_contributor!, only: [:turn_in]
  before_action :authenticate_past_or_current_contributor!, only: [:show]
  
  before_action :authenticate_can_download!, only: [:download, :download_inline]
  before_action :validate_and_set_assigned!, only: [:new, :new_professor, :create_professor, :create_blank, :index]
  before_action :validate_and_set_assigned_create!, only: [:create]
  before_action :validate_can_submit!, only: [:new, :create]
  before_action :validate_can_turn_in_repo!, only: [:turn_in]
  
  before_action :validate_and_set_user!, only: [:new_professor, :create_professor, :create_blank]
  
  before_action only: [:index, :create_blank] {authenticate_assigned_grader!(@assigned)}
  before_action only: [:grade, :adjustments, :render_file, :destroy, :force_turn_in, :un_turn_in, :add_file, :add_url, :reset_notification] {authenticate_assigned_grader!(@submission.assigned)}
  
  before_action only: [:new_professor, :create_professor] {authenticate_class_admin!(@assigned.klass)}
  
  # GET /submissions
  # GET /submissions.json
  def index
    #Get submissions for this assigned
	@submissions = Submission.where(assigned: @assigned).includes([
		graded_problems: [:checked_rubric_items],
		contributors: [
			user: [
				:extensions
			]
		],
		past_contributors:[
			user: [
				:extensions
			]
		],
		assigned: [
			assignment: [
				problems: [
					:rubric_items
				]
			]
		],
		regrade_requests: []
		
		])
		
	@no_submission = @assigned.klass.students.map{|s| s.user} - @submissions.map{|s| s.contributors}.flatten.map{|c| c.user}.uniq
  end
  
  # GET /submissions/1/render_file
  #def render_file
  #  f = @submission.get_file
  #  if f
  #  @ext = f.split(".")[-1]
  #	end
  # render layout: false
  #end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
    # Update feedback_seen for this user on this submission, if they are a contributor
	c = (@submission.contributors & current_user.contributors).first
	
	if c && !c.feedback_seen && @submission.graded? && !@submission.assigned.hide_grades?
	  # First time seeing feedback
	  # Don't trigger callbacks
	  c.update_column(:feedback_seen, true)
	end
  end

  # GET /submissions/1/grade
  def grade
    
  end
  
  
  # GET /submissions/new
  def new
	@submission = Submission.new
	@submission.assigned = @assigned
  end

  # GET /submissions/new_professor
  def new_professor
	@submission = Submission.new
	@submission.assigned = @assigned
  end
  

  # POST /submissions/1/turn_in
  def turn_in
    @submission.turned_in = true
	@submission.turned_in_time = DateTime.current
	@submission.save
    redirect_to submission_path(@submission), notice: "Assignment turned in!"
	Repo.refresh_repo_authorizations
	
	@submission.assigned.notify_graders_submitted(@submission)
  end
  
  
  # PATCH /submissions/1/adjustments
  def adjustments
    if @submission.update(adjustments_params)
	  redirect_to submission_grade_path(@submission), notice: "Updated grade adjustments."
	else
	  redirect_to submission_grade_path(@submission), alert: "Failed to update adjustments: "+@submission.errors.full_messages.join(", ")
	end
  end
  
  # POST /submissions
  # POST /submissions.json
  def create
   current_user.with_lock do
	@submission = Submission.new(submission_params)
	
	subtype = @assigned.assignment.file_or_link
	
	# If its a file, make sure the types are valid and number isn't too high
	if @assigned.assignment.student_file?
	  
	  if subtype=="both"
	    if params[:submission][:files].nil?
		  subtype = "provide_urls_only"
		elsif params[:links].nil?
		  subtype = "upload_files_only"
		end
	  end

	  if subtype=="upload_files_only"
	    # Are there any files?
	    unless params[:submission][:files]
	      redirect_to new_submission_path(assigned: @assigned), alert: "Please select at least one file to submit."
		  return
	   end
	  
	    # Are there too many files?
	    if params[:submission][:files].length > @assigned.assignment.file_limit
	      redirect_to new_submission_path(assigned: @assigned), alert: "You may only submit up to "+@assigned.assignment.file_limit.to_s+" file".pluralize(@assigned.assignment.file_limit)+"."
		  return
	    end
		
	  elsif subtype=="provide_urls_only"
	    # Are there any URLs?
	    unless params[:links] && params[:links].any?
	      redirect_to new_submission_path(assigned: @assigned), alert: "Please submit at least one URL."
		  return
	   end
	  
	    # Are there too many URLs?
	    if params[:links].length > @assigned.assignment.file_limit
	      redirect_to new_submission_path(assigned: @assigned), alert: "You may only submit up to "+@assigned.assignment.file_limit.to_s+" URL".pluralize(@assigned.assignment.file_limit)+"."
		  return
	    end
	  
	  else #both
	    # Are there any files or URLs?
	    unless params[:submission][:files] || params[:links]
	      redirect_to new_submission_path(assigned: @assigned), alert: "Please select at least one file or URL to submit."
		  return
	   end
	  
	    # Are there too many files and URLs?
	    if params[:submission][:files].length + params[:links].length > @assigned.assignment.file_limit
	      puts params[:submission][:files].length.to_s+" files"
		  puts params[:links].length.to_s + " links"
		  redirect_to new_submission_path(assigned: @assigned), alert: "You may only submit up to "+@assigned.assignment.file_limit.to_s+" file".pluralize(@assigned.assignment.file_limit)+" and URL".pluralize(@assigned.assignment.file_limit)+"."
		  return
	    end
	  end
	
	  # Are all the files valid types?
	  unless subtype=="provide_urls_only"
	    params[:submission][:files].each do |f|
	      unless @assigned.assignment.is_valid_filetype?(f.original_filename)
	        redirect_to new_submission_path(assigned: @assigned), alert: "Invalid file type: "+f.original_filename
		    return
	      end
	    end
	  end
	end
	
    respond_to do |format|
      if @submission.save
	    
		#Specific to assignment type
		
		if @assigned.assignment.student_file? || @assigned.assignment.student_repo?
		  #Make user a contributor to submission
		  c = Contributor.new(user: current_user, submission: @submission)
		  c.save
		end
		case @assigned.assignment.assignment_type
		when "student_file"
		  @submission.turned_in_time = DateTime.current
		  
		  #subtype = @assigned.assignment.file_or_link
		  
		  if subtype=="upload_files_only" || subtype=="both"
		    #Save files to assigned's repo
		    params[:submission][:files].each do |f|
      
			  #fname = current_user.get_preferred_name.gsub(/[^\w]/,'') + "-" + current_user.last_name.gsub(/[^\w]/,'') + "_"
			  fname = current_user.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'') + "_"
			
			  fname += f.original_filename.gsub(/[^\w\-\.]/,'_').split(".")[0..(f.original_filename.split(".").length-2)].join("_")
			
			  fname += "_s"+@submission.id.to_s+"."+f.original_filename.split(".")[-1].gsub(/[^\w\-]/,'_')

			  @assigned.repo.add_file([],fname,f.read,
			    current_user.get_full_real_name+" ("+current_user.id.to_s+") submitted on "  +DateTime.current.to_s)
		  
		    end
		  end
		  
		  if subtype=="provide_urls_only" || subtype=="both"
		    # Save each URL as a .kiturl file
			#Save files to assigned's repo
		    params[:links].each do |l|
			  n = l[:name]
			  url = l[:url]
			  
			  fname = current_user.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'') + "_"
			
			  fname += n.gsub(/[^\w\-\.]/,'_')
			
			  fname += "_s"+@submission.id.to_s+".kiturl"

			  @assigned.repo.add_file([],fname,url,
			    current_user.get_full_real_name + " ("+current_user.id.to_s+") submitted on "  +DateTime.current.to_s)
		  
		    end
		  end
		  
		  # Notify graders if they have requested it
		  @submission.assigned.notify_graders_submitted(@submission)
			
		when "student_repo"
		  #Clone the template repo from the assignment
		  r = Repo.new
		  r.save
		  @submission.repo = r
		  @submission.save
		  r.init_submission_repository(@assigned.assignment.template_repo)
		end
		
        format.html { redirect_to @submission, notice: 'Submission was successfully created.' }
        format.json { render :show, status: :created, location: @submission }
      else
        format.html { render :new }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
   end
  end
  
  # POST /submissions/new_professor
  def create_professor
    # Prevent double submissions by double clicking
    @user.with_lock do
	  if @assigned.assignment.student_file? || @assigned.assignment.professor_file?
	    if params[:submission][:files] || params[:links]
		  s = Submission.new(assigned: @assigned)
		  s.professor_uploaded = true
		  s.save!
      
		  c = Contributor.new(user: @user, submission: s)
		  c.save!
      
          feedback = params[:submission][:is_feedback]=="1"
          
		  if params[:submission][:files]
            params[:submission][:files].each do |f|
      
              fname = @user.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'')+ "_"
        
              fname += f.original_filename.gsub(/[^\w\-\.]/,'_').split(".")[0..(f.original_filename.split(".").length-2)].join("_")
        
              if feedback
                fname += "_f"
              else
                fname += "_s"
              end
              fname += s.id.to_s+"."+f.original_filename.split(".")[-1].gsub(/[^\w\-]/,'_')

              @assigned.repo.add_file([],fname,f.read,
                current_user.get_full_real_name+ " ("+current_user.id.to_s+") submitted on "  +DateTime.current.to_s)
            end
		  end
		  
		  if params[:links]
		    # Save each URL as a .kiturl file
			#Save files to assigned's repo
		    params[:links].each do |l|
			  n = l[:name]
			  url = l[:url]
			  
			  fname = @user.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'') + "_"
			
			  fname += n.gsub(/[^\w\-\.]/,'_')
			
			  if feedback
			    fname += "_f"
		      else
			    fname += "_s"
		      end
			  
			  fname += s.id.to_s+".kiturl"

			  @assigned.repo.add_file([],fname,url,
			    current_user.get_full_real_name+ " ("+current_user.id.to_s+") submitted on "  +DateTime.current.to_s)
		  
		    end
		  end
			
		  #redirect_to submission_grade_path(s), notice: "Submission uploaded."
		  redirect_to submissions_path(assigned: @assigned), notice: "Submission uploaded."
	    else
	      redirect_to submission_professor_new_upload_path(assigned: @assigned, user: @user), alert: "No files or URLs selected."
	    end
	  else
	    redirect_to root_url, alert: "Can't upload a file for that type of assignment."
	  end
	end
  end
  
  # POST /submissions/new_blank
  def create_blank
    # Prevent double submissions by double clicking
    @user.with_lock do
      # Create a blank submission for this student to be graded
	  s = Submission.new(blank: true, assigned: @assigned)
	  s.turned_in_time = DateTime.current
	  if @assigned.assignment.student_repo?
	    s.turned_in = true
	  end
	  s.save!
	
      c = Contributor.new(user: @user, submission: s)
	  c.save!
	
	redirect_to submission_grade_path(s), notice: "Blank submission created."
	end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    @submission.destroy
	
	if @submission.repo
	  @submission.repo.destroy
	end
	
    respond_to do |format|
      format.html { redirect_to submissions_url(assigned: @submission.assigned), notice: 'Submission was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  #def download
  #  p = @submission.get_file
	
	# if p
	  # f = File.open(p,"rb")
	  # send_data f.read, filename: p.split(File::SEPARATOR)[-1], disposition: 'attachment'
	  # f.close()
	# end
	
  # end
  
  
  def download
    files = @submission.get_files
	
	target = params[:filename]
	match = files.select{|f,t| f.split(File::SEPARATOR)[-1]==target}
	
	if match.any?
	  f = File.open(match.first[0],"rb")
	  send_data f.read, filename: match.first[0].split(File::SEPARATOR)[-1], disposition: 'attachment'
	  f.close()
	end
  end
  
  def download_inline
    files = @submission.get_files
	
	target = params[:filename]
	match = files.select{|f,t| f.split(File::SEPARATOR)[-1]==target}
	
	if match.any?
	  fn = match.first[0]
	  
	  if fn.split(".")[-1]=="kiturl"
	    f = File.open(match.first[0],"rb")
	    link = f.read
	    f.close()
		redirect_to link
	  else
	    f = File.open(match.first[0],"rb")
	    send_data f.read, filename: match.first[0].split(File::SEPARATOR)[-1], disposition: 'inline'
	    f.close()
	  end
	end
  end
  
  # def download_inline
    # p = @submission.get_file
	
	# if p
	  # #f = File.open(p,"rb")
	  # #mime_type = Mime::Type.lookup_by_extension(p.split(File::SEPARATOR)[-1].split('.')[-1])
      # #content_type = mime_type.to_s unless mime_type.nil?
	  # #headers['Content-Type'] = content_type
	  # #render file: p
	  # #headers['Access-Control-Allow-Origin'] = '*'
	  # #headers['Access-Control-Allow-Credentials'] = 'true'
	  # send_file p, disposition: 'inline', filename: p.split(File::SEPARATOR)[-1]
	  # #render plain: f.read
	  # #f.close()
	# end
  # end

  
  def force_turn_in
    if @submission.assigned.assignment.student_repo?
	  @submission.turned_in = true
	  @submission.turned_in_time = DateTime.current
	  if @submission.save
	    redirect_to submission_grade_path(@submission), notice: "Set submission to turned in."
		Repo.refresh_repo_authorizations
	  else
	    redirect_to submission_grade_path(@submission), alert: "Failed to set turned in: "+@submission.errors.full_messages.join(", ")
	  end
	else
	  redirect_to root_url, alert: "Invalid operation for non-repository assignment."
	end
  end
  
  
  def un_turn_in
    if @submission.assigned.assignment.student_repo?
	  @submission.turned_in = false
	  @submission.turned_in_time = nil
	  if @submission.save
	    redirect_to submission_grade_path(@submission), notice: "Set submission to not turned in."
		Repo.refresh_repo_authorizations
	  else
	    redirect_to submission_grade_path(@submission), alert: "Failed to set turned in: "+@submission.errors.full_messages.join(", ")
	  end
	else
	  redirect_to root_url, alert: "Invalid operation for non-repository assignment."
	end
  end
  
  
  def reset_notification
  
    @submission.update_column(:notified_graded, false)
	
	@submission.contributors.each do |c|
	  c.update_column(:feedback_seen, false)
	end
	
	@submission.notify_if_graded
  
	redirect_to submission_grade_path(@submission), notice: "Graded notification reset."
  end
  
  
  def add_file
    if @submission.assigned.assignment.has_uploaded_files?
	  feedback = params[:is_feedback]=="1"
	  
	  if params[:files]
	    params[:files].each do |f|
        fname = ""
        @submission.contributors.each do |c|
          fname += c.user.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'') + "_"
        end
        
        fname += f.original_filename.gsub(/[^\w\-\.]/,'_').split(".")[0..(f.original_filename.split(".").length-2)].join("_")
        
        if feedback
          fname += "_f"
        else
          fname += "_s"
        end
        fname += @submission.id.to_s+"."+f.original_filename.split(".")[-1].gsub(/[^\w\-\.]/,'_')
        
        @submission.assigned.repo.add_file([],fname,f.read,
            current_user.get_full_real_name+ " ("+current_user.id.to_s+") added files.")
        
      end
	  end
	  
	  redirect_to submission_grade_path(@submission), notice: "File(s) added."
	else
	  redirect_to root_url, alert: "Invalid operation for this assignment type."
	end
  end
  
  def add_url
    if @submission.assigned.assignment.has_uploaded_files?
	  feedback = params[:is_feedback]=="1"
	  
	  if params[:links]
	  
	    # Save each URL as a .kiturl file
		#Save files to assigned's repo
		params[:links].each do |l|
		  n = l[:name]
		  url = l[:url]
		  
		  fname = ""
          @submission.contributors.each do |c|
            fname += c.user.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'') + "_"
          end
		
		  fname += n.gsub(/[^\w\-\.]/,'_')
		  
		  if feedback
			fname += "_f"
		  else
			fname += "_s"
		  end
		  
		  fname += @submission.id.to_s+".kiturl"

		  @submission.assigned.repo.add_file([],fname,url,
			current_user.get_full_real_name+" ("+current_user.id.to_s+") submitted on "  +DateTime.current.to_s)
	  
		end
	  end
	  redirect_to submission_grade_path(@submission), notice: "URL(s) added."
	else
	  redirect_to root_url, alert: "Invalid operation for this assignment type."
	end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end
	
	def set_submission_c
	  @submission = Submission.find(params[:submission_id])
	end
	
	def validate_and_set_user!
	  @user = User.find(params[:user])
	  unless @user.get_student_classes.include?(@assigned.klass)
	    redirect_to root_url, alert: "Student with that ID is not in this class!"
	  end
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:assigned_id, :repo_id)
    end
	
	def adjustments_params
	  params.require(:submission).permit(:percent_modifier, :point_adjustment, :point_override, :overall_comments, :hide_rubric, :force_allow_resubmit)
	end
	
	def authenticate_contributor!
	  unless current_user.contributors.map {|c| c.submission}.include?(@submission)
	    redirect_to root_url
	  end
	end
	
	def authenticate_past_or_current_contributor!
	  unless current_user.contributors.map {|c| c.submission}.include?(@submission) || current_user.past_contributors.map{|c| c.submission}.include?(@submission)
	    redirect_to root_url
	  end
	end
	
	def authenticate_can_download!
	  unless current_user.contributors.map {|c| c.submission}.include?(@submission) || @submission.assigned.can_grade?(current_user)
	    redirect_to root_url
	  end
	end
	
	def validate_and_set_assigned!
	  unless params[:assigned] && Assigned.exists?(params[:assigned])
		redirect_to root_url
	  else
	    @assigned = Assigned.find(params[:assigned])
	  end
	end
	
	def validate_and_set_assigned_create!
	  unless submission_params[:assigned_id] && Assigned.exists?(submission_params[:assigned_id])
	    redirect_to root_url
	  else
	    @assigned = Assigned.find(submission_params[:assigned_id])
	  end
	end
	
	def validate_can_submit!
	  unless @assigned.student_can_submit?(@current_user)
	    redirect_to root_url, alert: "Failed to submit assignment."
	  end
	end
	
	def validate_can_turn_in_repo!
	  if @submission.assigned.assignment.assignment_type != "student_repo"
		redirect_to root_url, alert: "Invalid operation: only repository assignments use that URL!"
	  else
	    #Must not be overdue
		#if @submission.assigned.overdue? && !@submission.assigned.allow_late_submissions
		#  redirect_to klass_url(@submission.assigned.klass), alert: "Cannot submit: Assignment is late!"
		#end
		
		#Must not be turned in already
		if @submission.turned_in
		  redirect_to klass_url(@submission.assigned.klass), alert: "Cannot turn in: Already turned in!"
		end
		
	  end
	end
		
end
