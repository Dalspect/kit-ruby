class CreateGradedProblems < ActiveRecord::Migration[5.2]
  def change
    create_table :graded_problems do |t|
      t.belongs_to :problem, foreign_key: true
      t.belongs_to :submission, foreign_key: true
      t.text :comments
      t.decimal :point_adjustment
      t.belongs_to :grader, foreign_key: true

      t.timestamps
    end
  end
end
