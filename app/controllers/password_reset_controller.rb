class PasswordResetController < ApplicationController

  
  def show_password_reset_request
  end
  
  
  def request_password_reset
    email = params[:email].downcase
	
	u = User.where(email: email).first
	
	if u
	  u.new_password_reset_request!
	end
	
	redirect_to login_path, notice: "If a valid email has been supplied, an email with further instructions will be sent shortly."
  end
  
  
  def show_use_password_reset
  end
  
  
  def use_password_reset
    u = User.find(params[:user_id])
	
	if u && u.password_reset_valid?(params[:token])
	  #Token is valid and not timed out
	  
	  u.password = params[:new_password]
	  u.password_confirmation = params[:new_password_confirmation]
	  u.reset_digest = nil
	  
	  if u.save
	    redirect_to root_url, notice: "Password reset."
	  else
	    redirect_to show_use_password_reset_path(user: params[:user_id], token: params[:token]), alert: "New password and confirmation must match."
	  end
	else
	  redirect_to login_path, alert: "Password reset failed."
	end
  end
  
  
  
end
