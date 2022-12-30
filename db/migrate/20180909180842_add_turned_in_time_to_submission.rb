class AddTurnedInTimeToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :turned_in_time, :datetime
  end
end
