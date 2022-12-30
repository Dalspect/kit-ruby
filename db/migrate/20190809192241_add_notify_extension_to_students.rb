class AddNotifyExtensionToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :notify_extension, :boolean, default: false
  end
end
