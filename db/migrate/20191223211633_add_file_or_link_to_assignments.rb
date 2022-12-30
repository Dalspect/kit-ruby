class AddFileOrLinkToAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :file_or_link, :integer
  end
end
