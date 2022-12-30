class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions do |t|
      t.belongs_to :assigned, foreign_key: true
      t.references :repo, foreign_key: true

      t.timestamps
    end
  end
end
