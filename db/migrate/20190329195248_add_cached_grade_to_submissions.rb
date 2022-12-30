class AddCachedGradeToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :cached_grade, :decimal, precision: 16, scale: 4
  end
end
