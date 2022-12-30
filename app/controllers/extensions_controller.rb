class ExtensionsController < ApplicationController
  before_action :set_extension, only: [:edit, :update, :destroy]

  before_action :authenticate_logged_in!
  
  #Authenticate permission to give an extension
  before_action only: [:edit, :update, :destroy] {authenticate_assigned_grader!(@extension.assigned)}
  before_action only: [:new] {authenticate_assigned_grader!(Assigned.find(params[:assigned]))}
  before_action only: [:create] {authenticate_assigned_grader!(Assigned.find(extension_params[:assigned_id]))}
  
  # GET /extensions/new?user=1&assigned=1
  def new
    @extension = Extension.new
	@assigned = Assigned.find(params[:assigned])
	
	unless params[:user] && params[:assigned]
	  redirect_to root_url
	else
	  @extension.user_id = params[:user]
	  @extension.assigned_id = params[:assigned]
	end
  end

  # GET /extensions/1/edit
  def edit
    @assigned = @extension.assigned
  end

  # POST /extension
  def create
    @extension = Extension.new(extension_params)
	
    if @extension.save
      redirect_to submissions_path(assigned: @extension.assigned), notice: 'Extension was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /extensions/1
  def update
    if @extension.update(extension_params.except(:user_id, :assigned_id))
      redirect_to submissions_path(assigned: @extension.assigned), notice: 'Extension was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /extensions/1
  def destroy
    @extension.destroy
	
    redirect_to submissions_url(assigned: @extension.assigned), notice: 'Extension deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extension
      @extension = Extension.find(params[:id])
    end
	
	def extension_params
      params.require(:extension).permit(:user_id, :assigned_id, :allow_late_submissions, :new_deadline, :use_deadline_as_due_date, :allow_resubmissions, :limit_resubmissions, :resubmission_limit)
    end
end
