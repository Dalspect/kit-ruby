class AddAdvancedGradingToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :point_adjustment, :decimal
    add_column :submissions, :percent_modifier, :decimal
    add_column :submissions, :point_override, :boolean
  end
end
