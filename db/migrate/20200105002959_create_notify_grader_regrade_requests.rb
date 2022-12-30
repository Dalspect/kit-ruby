class CreateNotifyGraderRegradeRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :notify_grader_regrade_requests do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :assigned, foreign_key: true

      t.timestamps
    end
  end
end
