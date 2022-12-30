class ReposController < ApplicationController
  before_action :set_repo
  before_action :authenticate_logged_in!


  # GET repos/:id/download
  def download
    path = @repo.get_repository_read_directory + File::SEPARATOR + params[:dir].join(File::SEPARATOR)
    if @repo.is_safe_directory?(params[:dir]) && @repo.can_view_files_repo?(current_user,params[:dir]) && File.exist?(path)
	  
	  f = File.open(path,"rb")
	  send_data f.read, filename: params[:dir][-1], disposition: 'attachment'
	  f.close()
	  
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to download file."
	end
  end
  
  # GET repos/:id/view_file
  def view_file
    path = @repo.get_repository_read_directory + File::SEPARATOR + params[:dir].join(File::SEPARATOR)
    if @repo.is_safe_directory?(params[:dir]) && @repo.can_view_files_repo?(current_user,params[:dir]) && File.exist?(path)
	  
	  f = File.open(path,"rb")
	  send_data f.read, filename: params[:dir][-1], disposition: 'inline'
	  f.close()
	  
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to download file."
	end
  end
  
  # POST repos/:id/upload
  def add_file
    if @repo.is_safe_directory?(params[:dir]+[params[:file].original_filename]) && @repo.can_edit_files_repo?(current_user,params[:dir])
	  @repo.add_file(params[:dir], params[:file].original_filename, params[:file].read, 
	  current_user.get_full_real_name+ " ("+current_user.id.to_s+") uploaded "+params[:file].original_filename+" on "+DateTime.current.to_s)
	  
	  
	  redirect_to (params[:return_url] || root_url), notice: "File uploaded."
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to upload file."
	end
  end
  
  # POST repos/:id/add_directory
  def add_directory
    if @repo.is_safe_directory?(params[:dir]+[params[:name]]) && @repo.can_edit_files_repo?(current_user,params[:dir])
	  
	  @repo.add_directory(params[:dir], params[:name],
	    current_user.get_full_real_name+ " ("+current_user.id.to_s+") added directory "+params[:name]+" on "+DateTime.current.to_s)
	  
	  redirect_to (params[:return_url] || root_url), notice: "Directory created."
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to create directory."
	end
  end
  
  # POST repos/:id/upload
  def add_link
    if @repo.is_safe_directory?(params[:dir]+[params[:name]]) && @repo.can_edit_files_repo?(current_user,params[:dir])
	  @repo.add_file(params[:dir], params[:name]+".kiturl", params[:link], 
	  current_user.get_full_real_name+ " ("+current_user.id.to_s+") added link "+params[:name]+" on "+DateTime.current.to_s)
	  
	  
	  redirect_to (params[:return_url] || root_url), notice: "Link added."
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to add link."
	end
  end
  
  # DELETE repos/:id/file
  def delete_file
    path = @repo.get_repository_read_directory + File::SEPARATOR + params[:dir].join(File::SEPARATOR)
    if @repo.is_safe_directory?(params[:dir]) && @repo.can_edit_files_repo?(current_user,params[:dir]) && File.exist?(path)
	  
	  @repo.delete_file(params[:dir], current_user.get_full_real_name+ " ("+current_user.id.to_s+") deleted "+params[:dir].join(File::SEPARATOR)+" on "+DateTime.current.to_s)
	  
	  redirect_to (params[:return_url] || root_url), notice: "File deleted."
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to delete file."
	end
  end
  
  # DELETE repos/:id/directory
  def delete_directory
    if @repo.is_safe_directory?(params[:dir]) && @repo.can_edit_files_repo?(current_user,params[:dir])
	  @repo.delete_directory(params[:dir], 
	    current_user.get_full_real_name+" ("+current_user.id.to_s+") deleted directory "+params[:dir][-1]+" on "+DateTime.current.to_s)
	
	  redirect_to (params[:return_url] || root_url), notice: "Directory deleted."
	else
	  redirect_to (params[:return_url] || root_url), alert: "Failed to delete directory."
	end
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repo
      @repo = Repo.find(params[:id])
    end

	
	
end
