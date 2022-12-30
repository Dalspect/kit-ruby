class AddRepoToAssigned < ActiveRecord::Migration[5.2]
  def change
    add_reference :assigneds, :repo, foreign_key: true
  end
end
