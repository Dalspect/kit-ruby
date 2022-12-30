class AddProfessorUploadedToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :professor_uploaded, :boolean
  end
end
