class AddNotifyRegradeResponseToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :notify_regrade_response, :boolean
  end
end
