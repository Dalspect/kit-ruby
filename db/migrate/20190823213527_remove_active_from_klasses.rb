class RemoveActiveFromKlasses < ActiveRecord::Migration[5.2]
  def change
    remove_column :klasses, :active
  end
end
