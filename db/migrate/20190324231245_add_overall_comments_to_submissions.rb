class AddOverallCommentsToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :overall_comments, :string
  end
end
