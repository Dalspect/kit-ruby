class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :title
      t.references :repo, foreign_key: true

      t.timestamps
    end
  end
end
