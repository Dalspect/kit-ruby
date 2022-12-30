class AccountsMailer < ApplicationMailer

  def invite_user_email(user, token)
    @user_invite = user
	@link = show_user_invite_url(id: @user_invite.id, token: token)
	
	mail(to: @user_invite.email, subject: 'Kit Account Setup')
  end
  
  def password_reset_email(user, token)
    @user = user
	@link = show_use_password_reset_url(user: user.id, token: token)
	
	mail(to: user.email, subject: 'Kit Password Reset')
  end
  
end
