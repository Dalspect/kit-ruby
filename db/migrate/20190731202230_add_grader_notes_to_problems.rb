class AddGraderNotesToProblems < ActiveRecord::Migration[5.2]
  def change
    add_column :problems, :grader_notes, :text
  end
end
