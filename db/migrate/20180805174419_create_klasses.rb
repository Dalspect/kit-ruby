class CreateKlasses < ActiveRecord::Migration[5.2]
  def change
    create_table :klasses do |t|
      t.belongs_to :course, foreign_key: true
      t.references :repo, foreign_key: true
      t.boolean :active
      t.string :semester
      t.integer :section
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
