class FixOverallCommentLengthBug < ActiveRecord::Migration[5.2]
  def up
    change_column :submissions, :overall_comments, :text
  end
  # Just in case we need to go back
  def down
    change_column :submissions, :overall_comments, :string
  end
end
