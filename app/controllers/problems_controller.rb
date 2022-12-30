class ProblemsController < ApplicationController
  before_action :set_problem, only: [:edit, :update, :destroy]
  before_action :set_problem_c, only: [:move_up, :move_down]
  before_action :set_assignment
  
  before_action :authenticate_logged_in!
  
  before_action only: [:index, :new, :create] {authenticate_assignment_editor!(@assignment)}
  
  #The URL of the parent ID can be changed, so use stored one instead for existing problems
  before_action only: [:edit, :update, :destroy, :move_up, :move_down] {authenticate_assignment_editor!(@problem.assignment)}
  
  # GET /problems
  # GET /problems.json
  def index
    @problems = @assignment.problems
  end

  # GET /problems/new
  def new
    @problem = Problem.new
  end

  # GET /problems/1/edit
  def edit
  end

  # POST /problems
  # POST /problems.json
  def create
    @problem = Problem.new(problem_params)

	@problem.assignment = @assignment
	
    respond_to do |format|
      if @problem.save
	    RubricItem.create!(problem: @problem, title: "Full Credit", points: @problem.points, location: 0)
		RubricItem.create!(problem: @problem, title: "No Credit", points: 0, location: 1)
        format.html { redirect_to edit_assignment_problem_path(@assignment,@problem), notice: 'Problem was successfully created. Two example options were also created. Replace these with your rubric for this problem!' }
        format.json { render :show, status: :created, location: @problem }
      else
        format.html { render :new }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /problems/1
  # PATCH/PUT /problems/1.json
  def update
    respond_to do |format|
      if @problem.update(problem_params)
        format.html { redirect_to edit_assignment_problem_path(@assignment,@problem), notice: 'Problem was successfully updated.' }
        format.json { render :show, status: :ok, location: @problem }
      else
        format.html { render :edit }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /problems/1
  # DELETE /problems/1.json
  def destroy
    @problem.destroy
    respond_to do |format|
      format.html { redirect_to assignment_problems_url, notice: 'Problem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  
  def move_up
    if @problem.location > 0
	  @problem.location -= 1
	  
	  #Move current location holder down
	  above = @problem.assignment.problems.find_by(location: @problem.location)
	  above.location += 1
	  
	  # Save problems
	  @problem.save
	  above.save
	  
	  redirect_to assignment_problems_url(@problem.assignment)
	end
  end
  
  def move_down
    if @problem.location < @problem.assignment.problems.map{|p| p.location}.max
	  @problem.location += 1
	  
	  #Move current location holder down
	  below = @problem.assignment.problems.find_by(location: @problem.location)
	  below.location -= 1
	  
	  # Save problems
	  @problem.save
	  below.save
	  
	  redirect_to assignment_problems_url(@problem.assignment)
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_problem
      @problem = Problem.find(params[:id])
    end
	
	def set_problem_c
	  @problem = Problem.find(params[:problem_id])
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def problem_params
      params.require(:problem).permit(:title, :points, :grader_notes)
    end
	
	def set_assignment
	  @assignment = Assignment.find(params[:assignment_id])
	end
end
