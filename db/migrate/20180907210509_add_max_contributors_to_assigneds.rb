class AddMaxContributorsToAssigneds < ActiveRecord::Migration[5.2]
  def change
    add_column :assigneds, :max_contributors, :integer
  end
end
