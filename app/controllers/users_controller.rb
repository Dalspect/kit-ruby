class UsersController < ApplicationController
  before_action :set_user, only: [:show_invite, :accept_invite, :resend_invite, :edit_admin, :update, :destroy]

  before_action :authenticate_logged_in!, only: [:create, :index, :resend_invite, :edit_admin, :update, :destroy]
  
  before_action :authenticate_kit_admin!, only: [:create, :index, :destroy, :edit_admin, :resend_invite]
  before_action :set_self, only: [:edit_self]
  before_action :authenticate_can_edit_user!, only: [:update]
  
  
  # ----- Inviting and accepting invite ----- #
  
  def create
    invite = User.new
	invite.email = params[:email]
	invite.admin = params[:admin]
	
	invite.set_default_password
	
	
	if invite.save
	  redirect_to users_path, notice: "User invited!"
	else
	  redirect_to users_path, alert: "User not invited: "+invite.errors.full_messages.join(", ")
	end
  end
  
  def show_invite

  end
  
  def accept_invite
    if @user.valid_invite_token?(params[:user][:token])
	  #Lock invite to prevent exploit by accepting twice
	  #Also makes this block behave as a transaction
	  @user.with_lock do
	    @user.set_up = true
		
		# Make sure user entered a password
		# Since there is a random "default" password to make validations happy,
		# it is possible to not enter one here and have a random password nobody knows!
		if invite_params[:password].nil? || invite_params[:password]==""
		   redirect_to show_user_invite_path(user_invite: @user, token: params[:user][:token]), alert: "Please create a password for your account."
		else
		
		  if @user.update(invite_params)
		    redirect_to login_url, notice: "Account created!"
		  else
		    redirect_to show_user_invite_path(user_invite: @user, token: params[:user][:token]), alert: "Failed to create account: "+@user.errors.full_messages.join(", ")
		  end
		end
	  end
	else
	  redirect_to root_url, alert: "Invalid request!"
	end
  end
  
  def resend_invite
    @user.send_invite!
	redirect_to users_path, notice: "Invitation email resent."
  end
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/new
  #def new
  #  @user = User.new
  #end

  # GET /users/1/edit
  def edit_admin
  
  end
  
  def edit_self
    
  end
  
  def notification_settings
  
  end

=begin  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
=end
  
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
	  if current_user.admin?
        redirect_to users_url, notice: 'User was successfully updated.'
	  else
        redirect_to root_url, notice: 'Your settings have been successfully updated.'
	  end
    else
	  if current_user.admin?
        render :edit_admin
	  else
        render :edit
	  end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def change_password
  end
  
  def update_password
    #Make sure old password is correct
    if current_user.authenticate(params[:old_password])
	  u = current_user
	  
	  u.password = params[:new_password]
	  u.password_confirmation = params[:new_password_confirmation]
	  
	  #Try to update user, will fail if 
	  if u.save
	    redirect_to root_url, notice: "Password changed."
	  else
	    redirect_to change_password_path, alert: "New password and confirm password must match."
	  end
	  
	else
	  redirect_to change_password_path, alert: "Incorrect old password"
	end
  end

  private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
	  #If current user, can only update preferred name
	  #If admin, can update first and last name and check/uncheck admin
	  if current_user.admin?
        params.require(:user).permit(:admin, :first_name, :last_name, :preferred_name, :disabled)
	  elsif current_user == @user
	    params.require(:user).permit(:preferred_name)
	  end
    end
	
	def set_self
	  @user = current_user
	end
	
	def authenticate_can_edit_user!
	  unless current_user.admin? || current_user==@user
	    redirect_to root_url
	  end
	end
	
	def invite_params
      params.require(:user).permit(:first_name, :last_name, :preferred_name, :password, :password_confirmation)
    end

end