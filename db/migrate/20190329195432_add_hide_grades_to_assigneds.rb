class AddHideGradesToAssigneds < ActiveRecord::Migration[5.2]
  def change
    add_column :assigneds, :hide_grades, :boolean
  end
end
