class DepartmentProfessorsController < ApplicationController
  before_action :authenticate_logged_in!
  
  before_action :set_department, only: [:create, :update, :destroy]
  before_action :set_department_professor, only: [:update, :destroy]
  
  before_action only: [:update, :destroy] {authenticate_department_admin!(@department_professor.department)}
  before_action only: [:create] {authenticate_department_admin!(@department)}
  
  def create
	
	#Counters for success message
	added = []
	invited = []
	failed = []
	
	params[:department_professor][:emails].gsub(/[\s]/,'').split(',').each do |email|
	
	  #Check if email is already in the system
	  u = User.find_by email: email
	  if u
	    # User already exists
		dp = DepartmentProfessor.new(department_professor_params)
	    dp.department = @department
	    dp.user = user
        if dp.save
          added.push(email)
        else
          failed.push(email)
        end
	  else
	    # Invite user
		invite = User.new
		invite.email = email
		invite.set_default_password
		
		if invite.save
		  dp = DepartmentProfessor.new(department_professor_params)
	      dp.department = @department
	      dp.user = invite
		    
		  if dp.save
		    invited.push(email)
		  else
		    failed.push(email)
		  end
		else
	      failed.push(email)
		end
	  end
    end
	
	redirect_to edit_department_path(@department), notice: 
	  added.size.to_s + " professors added: "+added.join(", ")+"; "+invited.size.to_s + " professors invited: "+invited.join(", "),
	  alert: "Failed to add " + failed.size.to_s + " professors: "+failed.join(", ")
  end
  
  
  def update
    if @department_professor.update(department_professor_params)
	  redirect_to edit_department_path(@department), notice: "Professor updated."
	else
	  redirect_to edit_department_path(@department), alert: "Failed to update professor: "+@department_professor.errors.full_messages.join(", ")
	end
  end
  
  
  def destroy
    if @department_professor.destroy
	  redirect_to edit_department_path(@department_professor.department), notice: "Professor removed."
	else
	  redirect_to edit_department_path(@department_professor.department), alert: "Failed to remove professor: "+@department_professor.errors.full_messages.join(", ")
	end
  end
  
  
  private
  
  def set_department_professor
    @department_professor = DepartmentProfessor.find(params[:id])
  end
  
  def set_department
    @department = Department.find(params[:department_id])
  end
  
  def department_professor_params
    return params.require(:department_professor).permit(:admin)
  end
  
end