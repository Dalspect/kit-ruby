class CreateUserKlassInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :user_klass_invites do |t|
      t.belongs_to :klass, foreign_key: true
      t.belongs_to :user_invite, foreign_key: true

      t.timestamps
    end
  end
end
