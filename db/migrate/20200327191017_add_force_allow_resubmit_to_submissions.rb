class AddForceAllowResubmitToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :force_allow_resubmit, :boolean, default: false
  end
end
