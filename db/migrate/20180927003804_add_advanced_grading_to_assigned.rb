class AddAdvancedGradingToAssigned < ActiveRecord::Migration[5.2]
  def change
    add_column :assigneds, :max_points_override, :decimal
    add_column :assigneds, :point_value_scale, :decimal
  end
end
