class AddNotifiedGradedToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :notified_graded, :boolean, default: false
  end
end
