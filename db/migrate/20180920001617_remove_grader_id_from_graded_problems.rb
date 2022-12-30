class RemoveGraderIdFromGradedProblems < ActiveRecord::Migration[5.2]
  def change
    remove_column :graded_problems, :grader_id, :referrs_to
  end
end
