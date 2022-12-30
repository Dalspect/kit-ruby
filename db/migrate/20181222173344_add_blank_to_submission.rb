class AddBlankToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :blank, :boolean
  end
end
