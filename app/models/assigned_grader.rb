class AssignedGrader < ApplicationRecord
  belongs_to :user
  belongs_to :assigned
  
  # Validate that user is class grader
  # Validate assigned-user combo is unique
  
  validates :user, uniqueness: {scope: :assigned}
  validate :validate_is_class_grader
  
  after_create :notify_grader
  
  after_save {Repo.refresh_repo_authorizations}
  after_destroy {Repo.refresh_repo_authorizations}
  after_destroy {self.user.check_submission_notifications}
  
  private
  
  def validate_is_class_grader
    unless self.user.graders.map{|g| g.klass}.include?(self.assigned.klass)
	  self.errors.add(:base,"User is not a grader for this class!")
	end
  end
  
  def notify_grader
    g = self.user.graders.where(klass: self.assigned.klass).first
	
    if g.notify_grader_assigned?
	  NotificationMailer.grader_assigned(user, assigned).deliver_now
	  #AccountsMailer.password_reset_email(self, token).deliver_now
	end
  end
  
  
end
