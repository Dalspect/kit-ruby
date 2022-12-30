class CreateGradeCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :grade_categories do |t|
      t.string :title
      t.references :klass, foreign_key: true
      t.references :course, foreign_key: true
      t.decimal :weight

      t.timestamps
    end
  end
end
