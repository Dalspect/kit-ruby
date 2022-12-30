class CreateRegradeRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :regrade_requests do |t|
      t.references :submission, foreign_key: true
      t.text :reason
      t.boolean :closed, default: false
      t.text :response
      
      t.references :requested_by, foreign_key: {to_table: :users}
      t.references :closed_by, foreign_key: {to_table: :users}
      

      t.timestamps
    end
  end
end
