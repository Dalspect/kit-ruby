class AddNotificationSettingsToGraders < ActiveRecord::Migration[5.2]
  def change
    add_column :graders, :notify_grader_assigned, :boolean, default: false
  end
end
