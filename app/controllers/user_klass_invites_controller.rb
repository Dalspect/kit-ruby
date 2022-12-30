class UserKlassInvitesController < ApplicationController
  
  before_action :authenticate_logged_in!
  
  before_action :set_user_klass_invite

  before_action {authenticate_class_admin!(@user_klass_invite.klass)}

  def destroy
    @user_klass_invite.destroy!
	redirect_to @user_klass_invite.klass, notice: "Class removed from invitation."
  end

  
  private
  
  def set_user_klass_invite
    @user_klass_invite = UserKlassInvite.find(params[:id])
  end

end
