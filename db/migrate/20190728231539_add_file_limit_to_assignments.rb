class AddFileLimitToAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :file_limit, :integer, default: 1
  end
end
