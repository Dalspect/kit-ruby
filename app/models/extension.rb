class Extension < ApplicationRecord
  belongs_to :user
  belongs_to :assigned
  
  validates :user, uniqueness: {scope: :assigned}
  
  enum allow_resubmissions: [:never_resubmit, :resubmit_before_deadline, :resubmit_before_graded, :resubmit_even_after_graded]
  
  validate :validate_user_in_class
  
  after_save :notify_extension_granted
  
  def overdue?
	if new_deadline
	  t = DateTime.current
	  return (t > self.new_deadline)
	else
	  return assigned.overdue?
	end
  end
  
  private
  def validate_user_in_class
    unless self.user.get_student_classes.include?(self.assigned.klass)
	  errors.add(:base,"User is not in that assignment's class!")
	end
  end
  
  def notify_extension_granted
    s = self.user.students.find_by(klass: self.assigned.klass)
	if s.notify_extension?
	  NotificationMailer.extension_granted(self).deliver_now
	end
  end
end
