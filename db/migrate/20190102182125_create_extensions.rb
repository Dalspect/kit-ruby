class CreateExtensions < ActiveRecord::Migration[5.2]
  def change
    create_table :extensions do |t|
      t.boolean :allow_late_submissions
      t.datetime :new_deadline
      t.boolean :use_deadline_as_due_date
      t.boolean :limit_resubmissions
      t.integer :resubmission_limit
      t.integer :allow_resubmissions

      t.timestamps
    end
  end
end
