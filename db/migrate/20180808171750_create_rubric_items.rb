class CreateRubricItems < ActiveRecord::Migration[5.2]
  def change
    create_table :rubric_items do |t|
      t.belongs_to :problem, foreign_key: true
      t.string :title
      t.decimal :points
      t.integer :location

      t.timestamps
    end
  end
end
