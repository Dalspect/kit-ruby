class AddNotificationSettingsToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :notify_assignment_assigned, :boolean, default: false
    add_column :students, :notify_graded, :boolean, default: false
    add_column :students, :notify_contributor_invite, :boolean, default: false
  end
end
