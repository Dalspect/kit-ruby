class CreateNotifyGraderNewSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :notify_grader_new_submissions do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :assigned, foreign_key: true

      t.timestamps
    end
  end
end
