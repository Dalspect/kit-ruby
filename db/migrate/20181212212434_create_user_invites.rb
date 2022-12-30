class CreateUserInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :user_invites do |t|
      t.string :email
      t.string :token_digest
      t.boolean :admin

      t.timestamps
    end
  end
end
