class AddPasswordResetToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reset_digest, :string
    add_column :users, :reset_expires, :datetime
  end
end
