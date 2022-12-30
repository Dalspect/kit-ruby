class KlassesController < ApplicationController
  before_action :set_klass, only: [:show, :edit, :update, :destroy]
  before_action :set_klass_c, only: [:files]
  #before_action :set_klass_c, only: [:gradebook, :gradebook_csv]
  before_action :set_klass_gradebook, only: [:gradebook, :gradebook_csv]
  
  before_action :authenticate_logged_in!
  
  before_action only: [:new] {authenticate_department_professor!(Course.find(params[:course]).department)}
  before_action only: [:create] {authenticate_department_professor!(Course.find(klass_params[:course_id]).department)}

  before_action only: [:edit, :update, :gradebook, :gradebook_csv, :files] {authenticate_class_admin! @klass}
  before_action only: [:destroy] {authenticate_department_admin!(@klass.course.department)}
  before_action only: [:show] {authenticate_class_member! @klass}

  # GET /klasses
  # GET /klasses.json
  def index
    @klasses = Klass.all
	
	if current_user.get_student_classes.any?
	  # Figure out how many submissions have unread feedback_seen
	  # Faster to do it this way than per class in the view
	  unread_subs = current_user.contributors.includes(submission: {assigned: {assignment:{}, klass:{}}}).where(feedback_seen: false).map{|c| c.submission}
	  unread_subs = unread_subs.select{|s| s.graded? && !s.assigned.hide_grades?}
	  
	  @unread_counts = {}
	  unread_subs.each do |s|
	    id = s.assigned.klass_id
	    if @unread_counts[id]
		  @unread_counts[id] += 1
		else
		  @unread_counts[id] = 1
		end
	  end
	end
  end

  # GET /klasses/1
  # GET /klasses/1.json
  def show
    
	if current_user.get_grader_classes.include?(@klass)
	  
	  @assigneds = @klass.assigned.order(due_date: :desc).includes([
		submissions:[
			graded_problems:[:checked_rubric_items],
			contributors:[
				user: [:extensions]
			]
		],
		assigned_graders: [:user],
		assignment: [
			problems: [
				:rubric_items
			]
		]
	  ]).select{|ad| ad.assigned_graders.map{|ag| ag.user}.include?(current_user)}
	  
	  # Used for assignment status bar
	  @student_users = @klass.students.map{|s| s.user}
	end
  end
  
  def files
    #TODO
  end

  # GET /klasses/new
  def new
    @klass = Klass.new
	@klass.course_id = params[:course]
  end

  # GET /klasses/1/edit
  def edit
  end

  # POST /klasses
  # POST /klasses.json
  def create
    @klass = Klass.new(klass_params)
	r = Repo.create
    @klass.repo = r
	
    respond_to do |format|
	 begin
      if @klass.save
	    r.init_files_repository
		
		# Add creator as professor
		p = Professor.new
		p.klass = @klass
		p.user = current_user
		p.save!
		
        format.html { redirect_to klass_assignments_path(klass_id: @klass.id), notice: 'Class was successfully created.' }
      else
	    r.destroy
        format.html { render :new }
      end
	 rescue ActiveRecord::InvalidForeignKey
	  r.destroy
	  @klass.errors.add(:base, "Invalid Course ID!")
	  format.html { render :new }
      format.json { render json: @klass.errors, status: :unprocessable_entity }
	 end
    end
  end

  # PATCH/PUT /klasses/1
  # PATCH/PUT /klasses/1.json
  def update
    respond_to do |format|
      if @klass.update(klass_params)
        format.html { redirect_to edit_klass_path(@klass), notice: 'Class was successfully updated.' }
        format.json { render :show, status: :ok, location: @klass }
      else
        format.html { render :edit }
        format.json { render json: @klass.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /klasses/1
  # DELETE /klasses/1.json
  def destroy
    # Also automatically destroys repo
    @klass.destroy
    respond_to do |format|
      format.html { redirect_to klasses_url, notice: 'Class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /klasses/1/gradebook
  # GET /klasses/1/gradebook.csv
  def gradebook
    
  end
  
  # GET /klasses/1/gradebook.csv
  def gradebook_csv
	filename = ""
	if @klass.course
	  filename = @klass.course.course_code + "_"
	end
	filename += @klass.semester + "_" + @klass.section.to_s + "_" + DateTime.current.to_s(:short) + ".csv"
	
    send_data @klass.gradebook_as_csv(@assigneds), filename: filename, disposition: "download"
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_klass
      @klass = Klass.find(params[:id])
    end
	
	def set_klass_c
	  @klass = Klass.find(params[:klass_id])
    end
	
	def set_klass_gradebook
	  @klass = Klass.where(id: params[:klass_id]).includes([
		grade_category: [],
		assigned: [
			submissions:[
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
				]
			],
			assignment:[
				problems: [:rubric_items],
				grade_category: []
			]
		],
		students: [
			user: [
				contributors:[
					:submission
				]
			]
		],
		course:[
			:grade_category
		]
	  
	  ]).first
	  
	  @assigneds = @klass.assigned.order(due_date: :asc).includes([
		submissions:[
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
			]
		],
		assignment:[
			problems: [:rubric_items],
			grade_category: []
		]	  
	  ])
    end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def klass_params
      params.require(:klass).permit(:course_id, :active, :semester, :section, :start_date, :end_date)
    end
	
end
