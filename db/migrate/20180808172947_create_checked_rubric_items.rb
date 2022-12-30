class CreateCheckedRubricItems < ActiveRecord::Migration[5.2]
  def change
    create_table :checked_rubric_items do |t|
      t.belongs_to :rubric_item, foreign_key: true
      t.belongs_to :graded_problem, foreign_key: true

      t.timestamps
    end
  end
end
