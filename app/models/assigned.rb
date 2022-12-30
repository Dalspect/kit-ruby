class Assigned < ApplicationRecord
  belongs_to :assignment
  belongs_to :klass
  
  has_many :submissions, dependent: :destroy
  has_many :assigned_graders, dependent: :destroy
  has_many :extensions, dependent: :destroy
  has_many :notify_grader_new_submissions, dependent: :destroy
  has_many :notify_grader_regrade_requests, dependent: :destroy
  
  belongs_to :repo, optional: true, dependent: :destroy
  
  enum allow_resubmissions: [:never_resubmit, :resubmit_before_deadline, :resubmit_before_graded, :resubmit_even_after_graded]
  
  validate :validate_resubmission_limit
  
  validates :max_contributors, presence: true, numericality: {greater_than: 0}
  
  validates :klass, presence: true, uniqueness: {scope: :assignment}
  
  validate :validate_correct_class
  
  after_save :clear_grade_cache
  after_create :notify_students
  
  def get_user_submission(user)
	#Get submission that this user is a contributor to (& = intersection)
	intersect = self.submissions & (user.contributors.map {|c| c.submission})
	if intersect.empty?
	  return nil
	else
	  return intersect.first
	end
  end
  
  #Get assigned due date or due date set by extension
  def get_user_due_date(user)
    exts = user.extensions.where(assigned: self)
	if exts.any?
	  if exts.first.use_deadline_as_due_date?
	    return exts.first.new_deadline
	  else
	    return self.due_date
	  end
	else
	  return self.due_date
	end
  end
    
  def overdue?
    t = DateTime.current
	return (t > due_date)
  end
  
  def overdue_for?(user)
    # Where performance-critical, extensions should be preloaded anyway
	# Numerical comparison makes Rails not re-query, avoiding an n+1 issue
    exts = user.extensions.select{|e| e.assigned_id == self.id}
	if exts.any?
	  exts.first.overdue?
	else
	  self.overdue?
	end
  end
  
  def can_grade?(user)
    if user.graders.exists?(klass: self.klass) && self.assigned_graders.exists?(user: user)
      return true
    else
      return self.klass.is_class_admin?(user)
    end
  end
  
  #Get actual maximum points after adjusted
  def get_adjusted_max_grade
    if self.point_value_scale
	  self.point_value_scale
	else
	  get_unscaled_max_grade
	end
  end
  
  #Get max points, either from override or total of problems
  def get_unscaled_max_grade
    if self.max_points_override
	  self.max_points_override
	else
	  self.assignment.get_point_value
	end
  end
  
  #Count how many students have had submitted the assignment
  def count_turned_in
    sum = 0
	self.submissions.each do |s|
	  if s.turned_in?
	    sum += s.contributors.count
	  end
	end
	return sum
  end
  
  #Count how many submissions have been graded
  def count_graded
=begin    sum = 0
	self.submissions.each do |s|
	  if s.graded?
	    sum += s.contributors.count
	  end
	end
	return sum
=end
    self.submissions.count{|s| s.graded? && s.contributors.any?}
  end
  
  #Count how many submissions have NOT been graded
  #This also includes users who are overdue
  def count_ungraded
    sum = self.submissions.count{|s| !s.graded? && s.contributors.any?}
	
	#Also count users with no submission if assignment is overdue
	#Does not count users with extensions that have extended their due date
	if self.overdue?
	  sum += self.klass.students.map{|s| s.user}.count{|u| self.get_user_submission(u)==nil && (!u.extensions.where(assigned: self).any? || u.extensions.where(assigned: self).first.overdue?)}
	end
	
	return sum
  end
  
  
  #Can a particular user submit this assignment?
  #This method is only meant for students, professor uploads are almost always valid
  #This is NOT to be used for repo assignment "turn-ins" (marking complete)
  def student_can_submit?(user)
    #Can't turn in these types
	if self.assignment.professor_file? || self.assignment.grade_only?
	  return false
	end
	
	#Does user have an extension? If yes, use data from that. If not, use assigned data
	source = nil
	deadline = nil
	exts = user.extensions.where(assigned: self)
	if exts.any?
	  source = exts.first
	  deadline = source.new_deadline
	else
	  source = self
	  deadline = self.due_date
	end
	
	#Has this user already submitted this file?
	previous = get_user_submission(user)
	if previous
	  #User has already submitted, can they resubmit?
	  
	  # Force_allow_resubmit overrides all other settings
	  if previous.force_allow_resubmit?
	    return true
	  end
	  
	  #Have they reached a limited number of resubmissions?
	  if source.limit_resubmissions && user.past_contributors.select{|pc| pc.submission.assigned==self}.count >= source.resubmission_limit
	    return false
	  end
	  
	  #Depends on allow_resubmissions enum
	  case source.allow_resubmissions
	  when "never_resubmit"
	    return false
	  when "resubmit_before_deadline"
	    return !source.overdue?
	  when "resubmit_before_graded"
	    return !previous.graded?
	  when "resubmit_even_after_graded"
	    return true
	  end
	else
	  #User has not submitted anything yet
	  if source.overdue?
	    #Are late first submissions allowed?
	    return source.allow_late_submissions?
	  else
	    #Not overdue and no existing submission, of course they can submit
		return true
	  end
	end
  end
  
  def clear_grade_cache
    self.submissions.each do |s|
	  s.clear_grade_cache
	end
  end
  
  def notify_graders_submitted(submission)
    self.notify_grader_new_submissions.each do |ng|
	  NotificationMailer.submitted_to_grader(ng.user, submission).deliver_now
	end
  end
  
  def notify_graders_regrade_requested(regrade_request)
    self.notify_grader_regrade_requests.each do |ng|
	  NotificationMailer.regrade_requested(ng.user, regrade_request).deliver_now
	end
  end
  
  private
  def validate_correct_class
    if assignment.klass
	  if klass != assignment.klass
	    errors.add(:base,"Assignment cannot be assigned to a different class!")
	  end
	else #assignment is part of course
	  if klass.course != assignment.course
		errors.add(:base,"Assignment cannot be from a different course!")
	  end
	end
  end
  
  def validate_resubmission_limit
    if self.limit_resubmissions && self.resubmission_limit==nil
      errors.add(:base,"Please enter the maximum number of times a student may resubmit, or uncheck the 'Limit resubmission count' box.")
	end
  end
  
  def notify_students
    # Notify students of assigned assignment
	if self.assignment.student_responsible?
	  self.klass.students.each do |s|
		if s.notify_assignment_assigned?
		  NotificationMailer.assignment_assigned(s.user, self).deliver_now
		end
	  end
	end
  end
  
end
