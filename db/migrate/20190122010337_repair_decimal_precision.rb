class RepairDecimalPrecision < ActiveRecord::Migration[5.2]
  def change
    change_column :assigneds, :max_points_override, :decimal, precision: 16, scale: 4
    change_column :assigneds, :point_value_scale, :decimal, precision: 16, scale: 4
    change_column :grade_categories, :weight, :decimal, precision: 16, scale: 4
    change_column :graded_problems, :point_adjustment, :decimal, precision: 16, scale: 4
    change_column :problems, :points, :decimal, precision: 16, scale: 4
    change_column :rubric_items, :points, :decimal, precision: 16, scale: 4
    change_column :submissions, :point_adjustment, :decimal, precision: 16, scale: 4
    change_column :submissions, :percent_modifier, :decimal, precision: 16, scale: 4
  end
end
