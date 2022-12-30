class AddSetUpToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :set_up, :boolean, default: false
    add_column :users, :disabled, :boolean, default: false

    # Existing users are already set up and should not be magically un-set-up
    reversible do |d|
      d.up {
        User.all.each do |u|
          u.set_up = true;
          u.save!
        end
      }
      d.down {}
    end
  end
end
