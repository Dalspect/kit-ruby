class AddRelationsToExtensions < ActiveRecord::Migration[5.2]
  def change
    add_reference :extensions, :user, foreign_key: true
    add_reference :extensions, :assigned, foreign_key: true
  end
end
