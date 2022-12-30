class AddTurnedInToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :turned_in, :boolean
  end
end
