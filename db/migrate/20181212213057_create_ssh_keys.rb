class CreateSshKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :ssh_keys do |t|
      t.text :key
      t.belongs_to :user, foreign_key: true
      t.string :label

      t.timestamps
    end
  end
end
