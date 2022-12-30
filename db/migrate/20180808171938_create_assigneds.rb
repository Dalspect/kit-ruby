class CreateAssigneds < ActiveRecord::Migration[5.2]
  def change
    create_table :assigneds do |t|
      t.belongs_to :assignment, foreign_key: true
      t.belongs_to :klass, foreign_key: true
      t.datetime :due_date

      t.timestamps
    end
  end
end
