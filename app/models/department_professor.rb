class DepartmentProfessor < ApplicationRecord
  belongs_to :user
  belongs_to :department
  
  after_destroy {self.user.check_submission_notifications}
  after_update {self.user.check_submission_notifications}
  
  validates :user, uniqueness: {scope: :department}
end
