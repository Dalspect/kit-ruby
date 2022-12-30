class GradersController < ApplicationController
  before_action :set_grader, only: [:destroy, :toggle_assigned_notification]
  
  before_action :set_klass, only: [:index]
  
  before_action :authenticate_logged_in!
  
  before_action only: [:index] {authenticate_class_admin!(@klass)}
  before_action only: [:create] {authenticate_class_admin!(Klass.find(grader_params[:klass_id]))}
  before_action only: [:destroy] {authenticate_class_admin!(@grader.klass)}
  
  before_action :authenticate_self!, only: [:toggle_assigned_notification]

  def index
    #TODO
  end

  
  def create
  #Counters for success message
	added = []
	invited = []
	failed = []
	
	
	grader_params[:emails].gsub(/[\s]/,'').split(',').each do |email|
	
	  #Check if email is already in the system
	  u = User.find_by email: email
	  if u
	    # User already exists
		@grader = Grader.new
	    @grader.klass_id = grader_params[:klass_id]
	    @grader.user = u
        if @grader.save
          added.push(email)
        else
          failed.push(email)
        end
	  else
	    # Try to invite user
		invite = User.new
	    invite.email = email
	    invite.set_default_password
	  
	    if invite.save
		  grader = Grader.new
		  grader.klass_id = grader_params[:klass_id]
		  grader.user = invite
		
		  if grader.save
		    invited.push(email)
		  else
		    failed.push(email)
		  end
		else
		  failed.push(email)
		end
	  end
	end
	
	redirect_to klass_graders_path(grader_params[:klass_id]), notice: 
	  added.size.to_s + " graders added: "+added.join(", ")+"; "+invited.size.to_s+" invited: "+invited.join(", "),
	  alert: "Failed to add " + failed.size.to_s + " graders: "+failed.join(", ")
  
  end
  
  
  # DELETE /graders/1
  # DELETE /graders/1.json
  def destroy
    g = @grader.destroy
    respond_to do |format|
      format.html { redirect_to klass_graders_path(g.klass), notice: 'Grader was successfully removed.' }
      format.json { head :no_content }
    end
  end
  
  
  def toggle_assigned_notification
    @grader.toggle!(:notify_grader_assigned)
	if @grader.notify_grader_assigned
	  redirect_to notification_settings_path, notice: "Notifications enabled!"
	else
	  redirect_to notification_settings_path, notice: "Notifications disabled!"
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grader
      @grader = Grader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grader_params
      params.permit(:emails, :klass_id)
    end
	
	def set_klass
	  @klass = Klass.find(params[:klass_id])
	end
	
	def authenticate_self!
	  if @grader.user != current_user
	    redirect_to root_url, notice: "That action can only be performed on yourself!"
	  end
	end
end
