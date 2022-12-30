class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.string :title
      t.belongs_to :klass, foreign_key: true
      t.belongs_to :course, foreign_key: true
      t.belongs_to :grade_category, foreign_key: true
      t.references :files_repo
      t.references :template_repo

      t.timestamps
    end
  end
end
