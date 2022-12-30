class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_assignment_nested, only: [:view_copy_rubric, :copy_rubric]

  before_action :authenticate_logged_in!
  
  before_action only: [:show, :edit, :update, :destroy, :view_copy_rubric, :copy_rubric] { authenticate_assignment_editor!(@assignment) }
  
  before_action :authenticate_can_create!, only: [:create]
  
  
  before_action :set_klass_and_assignments, only: [:index]
  
  before_action only: [:index] {authenticate_class_admin!(@klass)}
  
  # GET klasses/:klass_id/assignments
  def index
    #TODO
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
	
    if params[:copy]
	  @allow_type = false
	  
	  @copied = Assignment.find(params[:copy])
	  
	  @assignment.title = @copied.title
	  @assignment.description = @copied.description
	  @assignment.assignment_type = @copied.assignment_type
	  @assignment.file_or_link = @copied.file_or_link
	  @assignment.permitted_filetypes = @copied.permitted_filetypes
	  @assignment.file_limit = @copied.file_limit
	else
      @allow_type = true
	  @assignment.file_limit = 1
	end
	
	if params[:course]
	  @assignment.course_id = params[:course]
	elsif params[:class]
	  @assignment.klass_id = params[:class]
	end
	
	
  end

  # GET /assignments/1/edit
  def edit
    @allow_type = false
  end

  # POST /assignments
  # POST /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)
	
	if params[:copy]
      @copy = Assignment.find(params[:copy])
	  @assignment.assignment_type = @copy.assignment_type
	else
	  @copy = nil
	end
	
	r = Repo.create
	@assignment.files_repo_id = r.id
	
	if @assignment.student_repo?
	  t = Repo.create
	  @assignment.template_repo_id = t.id
	end
	
    respond_to do |format|
	  begin
        if @assignment.save
		  if @copy
		    # Assignment is being duplicated
			# Duplicate files repository and template repository
			r.copy_files_repository(@copy.files_repo)
		    if t
		      t.copy_template_repository(@copy.template_repo)
		    end
			
			# Copy rubric
			@copy.problems.order(location: :asc).each do |p|
			  p.copy_problem(@assignment)
			end
			
		  else
		    r.init_files_repository
		    if t
		      t.init_blank_repository
		    end
		  end
		  
          format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
          format.json { render :show, status: :created, location: @assignment }
        else
	      r.destroy
		  if t
		    t.destroy
	      end
          format.html { render :new }
          format.json { render json: @assignment.errors, status: :unprocessable_entity }
        end
      rescue ActiveRecord::InvalidForeignKey
	    r.destroy
		if t
		  t.destroy
		end
		@assignment.errors.add(:base,"Invalid course or class ID!")
		format.html { render :new }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
	  end
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    p = assignment_params
	
	p[:assignment_type] = @assignment.assignment_type
	
    respond_to do |format|
      if @assignment.update(p)
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    a = @assignment.destroy
	
	if a.course
      redirect_to course_path(a.course), notice: 'Assignment was successfully destroyed.'
    elsif a.klass
	  redirect_to klass_assignments_path(a.klass), notice: 'Assignment was successfully destroyed.'
    end
  end
  
  def view_copy_rubric
  end
  
  
  def copy_rubric
	# Add selected to rubric, checking if user has access to them
	
	toCopy = params[:problems]
	
	toCopy.each do |id, checked|
		if checked=="1" && Problem.exists?(id)
		    p = Problem.find(id)
			p.with_lock do
				if (p.assignment.klass && p.assignment.klass.is_class_admin?(current_user)) ||
				 (p.assignment.course && (p.assignment.course.department.is_department_professor?(current_user)))
					# Copy problem
					p.copy_problem(@assignment)
				end
			end
		end
	end
	
	redirect_to assignment_problems_path(assignment_id: @assignment.id), notice: "Rubric items copied!"
  end
  
  
  def show_copy_assignment
    if params[:course]
	  @course = Course.find(params[:course])
	  @klass = nil
	elsif params[:klass]
	  @klass = Klass.find(params[:klass])
	  @course = nil
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end
	
	def set_assignment_nested
      @assignment = Assignment.find(params[:assignment_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.require(:assignment).permit(:title, :klass_id, :course_id, :grade_category_id, :assignment_type, :permitted_filetypes, :file_limit ,:description, :file_or_link)
    end
	
	def authenticate_can_create!
	  if !assignment_params[:klass_id].empty?
	    #Must be class admin
		k = Klass.find(assignment_params[:klass_id])
		authenticate_class_admin!(k)
	  else
	    #Must be department professor
		c = Course.find(assignment_params[:course_id])
		authenticate_department_professor!(c.department)
	  end
	  
	  if params[:copy]
	    authenticate_assignment_editor!(Assignment.find(params[:copy]))
	  end
	end
	
	def set_klass_and_assignments
	  @klass = Klass.where(id: params[:klass_id]).includes([
		students:[
			user: [:extensions, :contributors]
		],
	    graders:[
		]
	  ]).first
	
	  @klass_assignments = @klass.assignment.includes([
		problems: [
			:rubric_items
		],
		grade_category:[]
	  ])
	  
	  @course_assignments = @klass.course.assignment.includes([
		problems: [
			:rubric_items
		],
		grade_category:[]
	  ])
	  
	  @assigneds = @klass.assigned.includes([
		submissions:[
			graded_problems:[:checked_rubric_items],
			contributors:[
				user: [:extensions]
			],
			regrade_requests: []
		],
		assigned_graders:[],
		assignment: [
			problems: [
				:rubric_items
			]
		]
	  ])
	  
	  @student_users = @klass.students.map{|s| s.user}
	  
	end
	
	
	def find_possible_grade_categories
	  if @assignment.course
	    @assignment.course.grade_category
      else
	    @assignment.klass.get_grade_categories
	  end
	end
	helper_method :find_possible_grade_categories
end
