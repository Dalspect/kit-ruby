class ContributorInvitesController < ApplicationController
  before_action :authenticate_logged_in!
  before_action :set_contributor_invite, only: [:destroy]
  before_action :set_contributor_invite_parented, only: [:accept]

  before_action :authenticate_contributor!, only: [:create]
  before_action :authenticate_owner!, only: [:accept]
  before_action :authenticate_owner_or_contributor!, only: [:destroy]
  
  before_action :authenticate_can_submit!, only: [:accept]

  # POST /contributor_invites
  # POST /contributor_invites.json
  def create
    
	@contributor_invite = ContributorInvite.new
	
	@contributor_invite.submission = Submission.find(contributor_invite_params[:submission_id])
	
	if (@contributor_invite.submission.contributors.count + @contributor_invite.submission.contributor_invites.count) >= @contributor_invite.submission.assigned.max_contributors
	  @contributor_invite.errors.add(:base,"Maximum contributors reached!")
	  bad = true
	end
	
	@contributor_invite.user = User.find(contributor_invite_params[:user_id])

	if @contributor_invite.submission.contributors.map{|c| c.user}.include?(@contributor_invite.user)
	  @contributor_invite.errors.add(:base,"User is already a contributor!")
	  bad = true
	end
	
    respond_to do |format|
      if !bad && @contributor_invite.save
        format.html { redirect_to @contributor_invite.submission, notice: 'User invited!' }
        format.json { render :show, status: :created, location: @contributor_invite }
      else
        format.html { redirect_to @contributor_invite.submission, alert: 'User not invited: '+@contributor_invite.errors.full_messages.join(", ") }
        format.json { render json: @contributor_invite.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /contributor_invites/1/accept
  def accept
    c = Contributor.new(user: @contributor_invite.user, submission: @contributor_invite.submission)
	if c.save
	  @contributor_invite.destroy
	  redirect_to c.submission, notice: "Invitation accepted!"
	  
	  if @contributor_invite.submission.assigned.assignment.student_repo?
	    Repo.refresh_repo_authorizations
	  end
	end
  end

  # DELETE /contributor_invites/1
  # DELETE /contributor_invites/1.json
  def destroy
    @contributor_invite.destroy!
    if @contributor_invite.user == current_user
	  redirect_back fallback_location: root_url, notice: 'Invitation removed.'
	else
	  redirect_to @contributor_invite.submission, notice: 'Invitation removed.'
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contributor_invite
      @contributor_invite = ContributorInvite.find(params[:id])
    end

	def set_contributor_invite_parented
      @contributor_invite = ContributorInvite.find(params[:contributor_invite_id])
    end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def contributor_invite_params
      params.require(:contributor_invite).permit(:user_id, :submission_id)
    end
	
	def authenticate_contributor!
	  unless current_user.contributors.map {|c| c.submission}.include?(Submission.find(contributor_invite_params[:submission_id]))
	    redirect_to root_url
	  end
	end
	
	def authenticate_owner!
	  unless current_user == @contributor_invite.user
	    redirect_to root_url
	  end
	end
	
	def authenticate_owner_or_contributor!
	  unless current_user == @contributor_invite.user || (current_user.contributors.map {|c| c.submission}.include?(@contributor_invite.submission))
	    redirect_to root_url
	  end
	end
	
	def authenticate_can_submit!
	  unless @contributor_invite.submission.assigned.student_can_submit?(current_user)
	    redirect_to root_url, notice: "Failed to join submission!"
	  end
	end
end
