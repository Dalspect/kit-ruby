class RubricItemsController < ApplicationController
  before_action :set_rubric_item, only: [:update, :destroy]
  before_action :set_rubric_item_c, only: [:move_up, :move_down]
  before_action :set_assignment
  before_action :set_problem
  
  before_action :authenticate_logged_in!
  
  before_action only: [:create] {authenticate_assignment_editor!(@problem.assignment)}
  
  #The URL of the parent ID can be changed, so use stored one instead for existing problems
  before_action only: [:update, :destroy] {authenticate_assignment_editor!(@rubric_item.problem.assignment)}

  # POST /rubric_items
  # POST /rubric_items.json
  def create
    @rubric_item = RubricItem.new(rubric_item_params)
	

    respond_to do |format|
      if @rubric_item.save
        format.html { redirect_to parent_path, notice: 'Rubric option added.' }
        format.json { render :show, status: :created, location: @rubric_item }
      else
        format.html { redirect_to parent_path, alert: "Failed to add option! Make sure to specify a text string and point value." }
        format.json { render json: @rubric_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rubric_items/1
  # PATCH/PUT /rubric_items/1.json
  def update
    respond_to do |format|
      if @rubric_item.update(rubric_item_params)
        format.html { redirect_to parent_path, notice: 'Rubric option was successfully updated.' }
        format.json { render :show, status: :ok, location: @rubric_item }
      else
        format.html { redirect_to parent_path, alert: 'Failed to update rubric option!' }
        format.json { render json: @rubric_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rubric_items/1
  # DELETE /rubric_items/1.json
  def destroy
    @rubric_item.destroy
    respond_to do |format|
      format.html { redirect_to parent_path, notice: 'Rubric option removed.' }
      format.json { head :no_content }
    end
  end
  
  
   def move_up
    if @rubric_item.location > 0
	  @rubric_item.location -= 1
	  
	  #Move current location holder down
	  above = @rubric_item.problem.rubric_items.find_by(location: @rubric_item.location)
	  above.location += 1
	  
	  # Save problems
	  @rubric_item.save
	  above.save
	  
	  redirect_to edit_assignment_problem_path(@assignment,@rubric_item.problem)
	end
  end
  
  def move_down
    if @rubric_item.location < @rubric_item.problem.rubric_items.map{|p| p.location}.max
	  @rubric_item.location += 1
	  
	  #Move current location holder down
	  below = @rubric_item.problem.rubric_items.find_by(location: @rubric_item.location)
	  below.location -= 1
	  
	  # Save problems
	  @rubric_item.save
	  below.save
	  
	  redirect_to edit_assignment_problem_path(@assignment,@rubric_item.problem)
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rubric_item
      @rubric_item = RubricItem.find(params[:id])
    end

	def set_rubric_item_c
      @rubric_item = RubricItem.find(params[:rubric_item_id])
    end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def rubric_item_params
      params.permit(:problem_id, :title, :points)
    end
	
	def parent_path
	  edit_assignment_problem_path(params[:assignment_id], params[:problem_id])
	end
	
	def set_assignment
	  @assignment = Assignment.find(params[:assignment_id])
	end
	
	def set_problem
	  @problem = Problem.find(params[:problem_id])
	end
end
