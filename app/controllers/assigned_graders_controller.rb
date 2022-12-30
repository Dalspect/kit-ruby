class AssignedGradersController < ApplicationController
  before_action :authenticate_logged_in!
  
  before_action :set_assigned_grader, only: [:destroy]
  before_action :set_assigned_and_user, only: [:create]
  
  before_action only: [:create] {authenticate_class_admin!(@assigned.klass)}
  before_action only: [:destroy] {authenticate_class_admin!(@assigned_grader.assigned.klass)}
  
  # POST /assigned_graders
  # POST /assigned_graders.json
  def create
    @assigned_grader = AssignedGrader.new
	@assigned_grader.assigned = @assigned
	@assigned_grader.user = @user

    respond_to do |format|
      if @assigned_grader.save
        format.html { redirect_to assignment_grade_settings_path(@assigned.assignment, @assigned), notice: 'Grader added!' }
        format.json { render :show, status: :created, location: @assigned_grader }
      else
        format.html { redirect_to assignment_grade_settings_path(@assigned.assignment, @assigned), alert: 'Grader not added: '+@assigned.errors.full_messages.join(", ") }
        format.json { render json: @assigned_grader.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assigned_graders/1
  # DELETE /assigned_graders/1.json
  def destroy
    @assigned_grader.destroy
    redirect_to assignment_grade_settings_path(@assigned_grader.assigned.assignment, @assigned_grader.assigned), notice: 'Grader removed!'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assigned_grader
      @assigned_grader = AssignedGrader.find(params[:id])
    end
	
	def set_assigned_and_user
	  if params[:user] && User.exists?(params[:user])
	    @user = User.find(params[:user])
	  else
	    redirect_to root_url, alert: "Couldn't find specified user!"
	  end
	  
	  if params[:assigned] && Assigned.exists?(params[:assigned])
	    @assigned = Assigned.find(params[:assigned])
	  elsif @user
	    #Avoid redirecting twice
	    redirect_to root_url, alert: "Couldn't find specified assignment!"
	  end
	end
end
