class Submission < ApplicationRecord
  belongs_to :assigned
  belongs_to :repo, dependent: :destroy, optional: true
  
  has_many :graded_problems, dependent: :destroy
  has_many :contributors, dependent: :destroy
  has_many :past_contributors, dependent: :destroy
  has_many :regrade_requests, dependent: :destroy
  
  has_many :contributor_invites, dependent: :destroy

  validates :percent_modifier, presence: true
  
  before_validation :default_percent, on: :create
  
  after_destroy :remove_file
  
  after_update :clear_grade_cache
  
  validate :validate_point_override_value_set
  
  def graded?
    #Every problem must have a graded problem, which must have at least one rubric item checked
	#Overridden if point_override set
	#Since graded problems validate that they have a unique problem in the submission, we can count as a first check
	
	num_probs = self.assigned.assignment.problems.length
	
	if self.cached_grade
	  return true
	elsif self.point_override
	  # Score overridden to value of master adjustment
	  return true
	elsif self.graded_problems.length != num_probs || num_probs==0
	  # Not enough problems
	  return false
	else
	  # Make sure all the problems are graded
	  self.graded_problems.each do |gp|
	    unless gp.graded?
		  # Problem not graded -> submission not graded
		  return false
		end
	  end
	  
	  # All problems were graded
	  return true
	end
  end
  
  # Old version: returned some object when graded was true without cache, new one is faster and doesn't do that
  # On production, old usually takes above 4s while new is usually below 4s (running on all submissions)
  # def graded?
  
    # if self.cached_grade
	  # return true
	# end
    # Every problem must have a graded problem, which must have at least one rubric item checked
	# Overridden if point_override set
	# Since graded problems validate that they have a unique problem in the submission, we can count as a first check
	# if self.point_override
	  # return true
	# else
	  # self.assigned.assignment.problems.each do |problem|
	    # if self.graded_problems.map{|gp| gp.problem}.include?(problem)
	      # unless self.graded_problems.find_by(problem: problem).graded?
	        # return false
		  # end
        # else
	      # return false
	    # end
	  # end
    # end
  # end
  
  def get_raw_grade_points
    #unless self.graded?
	#  return nil
	#end
	
	if self.point_override
	  return point_adjustment
	end
	
	#Grade is sum of checked rubric items & adjustments
	sum = 0
	self.graded_problems.each do |p|
	  sum += p.get_grade_points
	end
	return sum
  end
  
  def get_adjusted_grade_points
    
    if self.cached_grade
      return self.cached_grade
    end
    
    unless self.graded?
      return nil
    end
    
    score = self.get_raw_grade_points
    
    if self.point_adjustment && !self.point_override
      score += point_adjustment
    end
    
    score *= (self.percent_modifier / 100)
    
    if self.assigned.point_value_scale
      score /= self.assigned.get_unscaled_max_grade
      score *= self.assigned.point_value_scale
    end
    
    # Update_column doesn't trigger callbacks or validations, which is usually bad but here we don't want this to trigger recursively
    update_column(:cached_grade, score)
    
    return score
  end
  
  def get_grade_percent
    100*(self.get_adjusted_grade_points / self.assigned.get_adjusted_max_grade)
  end
  
  #When not a student repo a submission existing means it is turned in
  def turned_in?
    if self.assigned.assignment.assignment_type == "student_repo"
	  return turned_in
	else
	  return true
	end
  end
  
  def get_time_turned_in
    if self.assigned.assignment.assignment_type == "student_repo"
	  return self.turned_in_time
	else
	  return self.created_at
	end
  end
  
  def count_graded_problems
    sum = 0
    self.graded_problems.each do |p|
	  if p.graded?
	    sum += 1
	  end
	end
	
	return sum
  end
  
  
  # def get_file
    # #Find file in assigned repo ending in sID.something
    # dir = self.assigned.repo.get_repository_read_directory
	
	# #There had better only be one file in this glob or something is really wrong
	# g = Dir.glob(dir+File::SEPARATOR+"*s"+self.id.to_s+".*")
	
	# if g.any?
	  # return g[0]
	# else
	  # return nil
	# end
  # end
  
  # Returns an array of two-entry arrays
  def get_files
    #Find file in assigned repo ending in sID.something or fID.something
    dir = self.assigned.repo.get_repository_read_directory
	
	#Get submission files
	s = Dir.glob(dir+File::SEPARATOR+"*s"+self.id.to_s+".*").map{|file| [file,:submitted]}
	
	#Get feedback files
	f = Dir.glob(dir+File::SEPARATOR+"*f"+self.id.to_s+".*").map{|file| [file,:feedback]}

	return s+f
  end
  
  #If a submission has multiple contributors, the due date is the one for the latest user (if extensions used)
  #If a submission has no contributors use the past contributors
  def get_due_date
    c = self.contributors.map{|c| c.user}
    unless c.any?
	  c = self.past_contributors.map{|c| c.user}
	end
	
	return c.map{|u| self.assigned.get_user_due_date(u)}.max
  end
  
  def clear_grade_cache
	# Update_column doesn't trigger callbacks or validations, which is usually bad but here we don't want this to trigger recursively
	update_column(:cached_grade, nil)
	
	unless self.assigned.hide_grades? || self.notified_graded?
	  $check_if_graded_for_notification.push(self.id)
	end
  end
  
  
  def notify_if_graded
    # Check if a graded notification is necessary
    unless self.notified_graded? || self.assigned.hide_grades?
	  if self.graded?
	    # Submission is graded but no notification has been sent yet
	    # Notify contributors that work is graded
		
		self.contributors.each do |c|
		  u = c.user
		  s = u.students.where(klass: self.assigned.klass).first
		  
		  if s.notify_graded?
		    NotificationMailer.submission_graded(u, self).deliver_now
		  end
		  
		end
		
		update_column(:notified_graded, true)
	  end
	end
  end
  
  
  def notify_contributors_regrade_response(regrade_request)
    
	contribs = self.assigned.klass.students.where(notify_regrade_response: true) &  self.contributors.map{|c| c.user.students}.flatten
	contribs.each do |s|
	  NotificationMailer.regrade_response(s.user,regrade_request).deliver_now
	end
  end
  
  
  def has_active_regrade_request?
    return self.regrade_requests.where(closed: false).any?
  end
  
  private
  
  def default_percent
    self.percent_modifier ||= 100
	return true
  end
  
  def remove_file
    if self.assigned.assignment.has_uploaded_files?
      self.get_files.each do |f, t|
	    self.assigned.repo.delete_file([f.split(File::SEPARATOR)[-1]],"Submission "+self.id.to_s+" deleted from database.")
	  end
    end
  end
  
  def validate_point_override_value_set
    if self.point_override && self.point_adjustment == nil
	    errors.add(:base,"If override grade is set, point adjustment must also be set because that is the value that will be used for this submission's grade.")
	  end
  end
  
end
