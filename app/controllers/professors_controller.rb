class ProfessorsController < ApplicationController
  before_action :set_professor, only: [:destroy]
  
  before_action :authenticate_logged_in!
  
  before_action only: [:destroy] {authenticate_class_admin!(@professor.klass)}
  before_action only: [:create] {authenticate_class_admin!(Klass.find(professor_params[:klass_id]))}
  

  def create
  #Counters for success message
	added = []
	invited = []
	failed = []
	
	professor_params[:emails].gsub(/[\s]/,'').split(',').each do |email|
	
	  #Check if email is already in the system
	  u = User.find_by email: email
	  if u
	    # User already exists
		@professor = Professor.new
	    @professor.klass_id = professor_params[:klass_id]
	    @professor.user = u
        if @professor.save
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
		  p = Professor.new
		  p.klass_id = professor_params[:klass_id]
		  p.user = invite
		    
		  if p.save
		    invited.push(email)
		  else
		    failed.push(email)
		  end
		else
	      failed.push(email)
		end
	  end
	end
	
	redirect_to edit_klass_path(professor_params[:klass_id]), notice: 
	  added.size.to_s + " admins added: "+added.join(", ")+"; "+invited.size.to_s + " admins invited: "+invited.join(", "),
	  alert: "Failed to add " + failed.size.to_s + " admins: "+failed.join(", ")
  
  end
  

  # DELETE /professors/1
  # DELETE /professors/1.json
  def destroy
    p = @professor.destroy
    respond_to do |format|
      format.html { redirect_to edit_klass_path(p.klass), notice: 'Professor was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_professor
      @professor = Professor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def professor_params
      params.permit(:emails, :klass_id)
    end
end
