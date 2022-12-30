class UserInvitesController < ApplicationController
  
  before_action :authenticate_logged_in!, only: [:create, :destroy, :resend]
  
  before_action :authenticate_kit_admin!, only: [:create, :destroy, :resend]
  
  before_action :set_user_invite, only: [:destroy, :show, :accept, :resend]
  
  

  def destroy
    @user_invite.destroy!
	redirect_to users_path, notice: "Invite removed, invitation link is now invalid."
  end


  

  
  
  private
  
  def set_user_invite
    @user_invite = UserInvite.find(params[:id])
  end
  
  
end
