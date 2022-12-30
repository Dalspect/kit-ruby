class AddGraderIdToGradedProblems < ActiveRecord::Migration[5.2]
  def change
    add_column :graded_problems, :grader_id, :integer
  end
end
