class CreateContributors < ActiveRecord::Migration[5.2]
  def change
    create_table :contributors do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :submission, foreign_key: true

      t.timestamps
    end
  end
end
