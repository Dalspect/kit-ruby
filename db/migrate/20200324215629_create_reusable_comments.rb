class CreateReusableComments < ActiveRecord::Migration[5.2]
  def change
    create_table :reusable_comments do |t|
      t.belongs_to :problem, foreign_key: true
      t.text :comment

      t.timestamps
    end
  end
end
