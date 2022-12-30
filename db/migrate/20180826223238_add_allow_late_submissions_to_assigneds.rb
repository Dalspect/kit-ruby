class AddAllowLateSubmissionsToAssigneds < ActiveRecord::Migration[5.2]
  def change
    add_column :assigneds, :allow_late_submissions, :boolean
  end
end
