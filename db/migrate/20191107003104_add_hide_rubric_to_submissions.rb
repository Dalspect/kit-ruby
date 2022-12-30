class AddHideRubricToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :hide_rubric, :boolean, default: false
  end
end
