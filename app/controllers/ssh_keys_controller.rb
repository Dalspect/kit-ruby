class SshKeysController < ApplicationController
  before_action :set_ssh_key, only: [:destroy]
  
  before_action :authenticate_logged_in!

  # GET /ssh_keys
  # GET /ssh_keys.json
  def index
    @ssh_keys = current_user.ssh_keys
  end

  # GET /ssh_keys/new
  def new
    @ssh_key = SshKey.new
  end

  # POST /ssh_keys
  # POST /ssh_keys.json
  def create
    @ssh_key = SshKey.new(ssh_key_params)
    @ssh_key.user = current_user
    if @ssh_key.save
      redirect_to ssh_keys_path, notice: 'SSH key was successfully added to your account.'
    else
	  render :new
	end
  end


  # DELETE /ssh_keys/1
  # DELETE /ssh_keys/1.json
  def destroy
    @ssh_key.destroy
    redirect_to ssh_keys_path, notice: 'Ssh key was successfully removed from your account.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ssh_key
      @ssh_key = SshKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ssh_key_params
      params.require(:ssh_key).permit(:key, :label)
    end
end
