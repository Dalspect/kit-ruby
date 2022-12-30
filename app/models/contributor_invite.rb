class ContributorInvite < ApplicationRecord
  belongs_to :user
  belongs_to :submission
  
  validates :user, presence: true
  validates :submission, presence: true
  
  validates :user, uniqueness: {scope: :submission}
  
  validate :validate_user_in_class
  after_create :notify_student
  
  private
  
  def validate_user_in_class
    unless self.user && self.user.get_student_classes.include?(self.submission.assigned.klass)
	  errors.add(:base,"User is not a student in this class!")
	end
  end
  
  def notify_student
    # Notify student of invitation
	if self.user.students.where(klass: self.submission.assigned.klass).first.notify_contributor_invite?
	  NotificationMailer.contributor_invite(self.user, self.submission).deliver_now
	end
  end
  
  
end
