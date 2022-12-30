class Student < ApplicationRecord
  belongs_to :user
  belongs_to :klass
  
  #Should remove any contributor entries
  after_destroy :destroy_contributors!
  
  validates :user, uniqueness: {scope: :klass}
  
  after_create {Repo.refresh_repo_authorizations}
  after_destroy {Repo.refresh_repo_authorizations}
  
  
  
  def count_on_time_late
    subs = self.user.submissions.select{|s| s.assigned.klass==self.klass && s.turned_in? && !s.blank? && !s.professor_uploaded?}
	
	late = subs.select{|s| s.get_time_turned_in > s.get_due_date}.count
	
	return {on_time: (subs.count-late), late: late}
  end
  
  def count_overdue
    blank = self.user.submissions.select{|s| s.assigned.klass==self.klass && s.blank? && !s.assigned.assignment.grade_only?}.count
	overdue = self.klass.assigned.select{|a| a.get_user_submission(self.user)==nil && a.overdue_for?(self.user) && (a.assignment.student_file? || a.assignment.student_repo?)}.count
	return blank+overdue
  end
  
  def count_resubmissions
    self.user.past_contributors.select{|c| c.submission.assigned.klass==self.klass}.count
  end

  def count_extensions
    self.user.extensions.select{|e| e.assigned.klass==self.klass}.count
  end
  
  private
  
  def destroy_contributors!
    self.user.contributors.each do |c|
	  if c.submission.assigned.klass == self.klass
	    c.destroy
	  end
	end
	self.user.contributor_invites.each do |c|
	  if c.submission.assigned.klass == self.klass
	    c.destroy
	  end
	end
  end
end
