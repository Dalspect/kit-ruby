class AddPermittedFiletypesToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :permitted_filetypes, :string
  end
end
