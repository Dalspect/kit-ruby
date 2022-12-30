class SessionsController < ApplicationController
  before_action :check_user_offline, only: [:new, :create]
  
  before_action :authenticate_logged_in!, only: [:enable_file_viewer,:disable_file_viewer]
  
  def new
  end
  
  def file_viewer_settings
  end
  
  def save_file_viewer_settings
    session[:file_viewer_filter] = params[:filter]
	
	redirect_to params[:return_url], notice: "Settings updated."
  end
  
  def create
    #Get user by email, or nil if not found
    user = User.find_by(email: params[:email])
	#If not nil and password correct, log in
	if user && user.set_up && !user.disabled && user.authenticate(params[:password])
	  #Store user id in cookies
	  session[:user_id] = user.id
	  redirect_to root_url, notice: "Logged in! Welcome, "+current_user.get_preferred_first_name+"!"
	else
	  #Re-render page with error
	  redirect_to login_path, alert: "Invalid email or password, please try again."
	end
  end
  
  def destroy
    #Remove user id from session cookies
	session[:user_id] = nil
	redirect_to login_path, notice: "You are now logged out. Have a nice day!"
  end
  
  def enable_file_viewer
    session[:enable_file_viewer] = true
	redirect_back(fallback_location: root_url, notice: "File viewer enabled.")
  end
  
  def disable_file_viewer
    session[:enable_file_viewer] = nil
	redirect_back(fallback_location: root_url, notice: "File viewer disabled.")
  end
  
  private
    def check_user_offline
	  if current_user
	    redirect_to root_url
      end
	end
end
