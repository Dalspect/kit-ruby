class AddResubmissionsToAssigned < ActiveRecord::Migration[5.2]
  def change
    add_column :assigneds, :limit_resubmissions, :boolean
    add_column :assigneds, :resubmission_limit, :integer
    add_column :assigneds, :allow_resubmissions, :integer
  end
end
