class GradeCategory < ApplicationRecord
  # Note: Previously classes could have their own grade categories if they were not part of a course.
  # This has been temporarily disabled since we removed courseless classes,
  # but support for it has been left in since we have discussed adding class level category overrides
  # or something similar later.
  
  belongs_to :course#, optional: true
  belongs_to :klass, optional: true
  
  has_many :assignments
  
  validates :title, presence: true
  validates :weight, presence: true
  
  validate :class_or_course
  
  """
  # Performance is concerning with these grade calculations, need to try some sql tricks to speed it up
  def get_category_max_points(klass, user)
    #klass.assigned.where(assignment.grade_category==self).sum{|a| a.get_adjusted_max_grade}
	
	#user.submissions.joins(:assigned).where(assigned: {klass: klass}).where(assigned: {assignment: {grade_category: self}}).sum{|a| a.get_adjusted_max_grade}
	
	sum = 0
    user.submissions.each do |s|
	  if s.assigned.klass==klass && s.assigned.assignment.grade_category==self && s.graded? && !s.assigned.hide_grades?
	    sum += s.assigned.get_adjusted_max_grade
	  end
	end
	
	return sum
  end
  
  def get_category_grade_points(klass, user)
    sum = 0
    user.submissions.each do |s|
	  if s.assigned.klass==klass && s.assigned.assignment.grade_category==self && s.graded? && !s.assigned.hide_grades?
	    sum += s.get_adjusted_grade_points
	  end
	end
	
	return sum
  end
  """
  
  def get_category_max_points(klass, user)
	sum = 0
	klass.assigned.each do |ad|
	  if ad.assignment.grade_category==self && !ad.hide_grades?
		s = ad.get_user_submission(user)
		if s && s.graded?
		  sum += ad.get_adjusted_max_grade
		end
	  end
	end
	
	return sum
  end
  
  def get_category_grade_points(klass, user)
    sum = 0
	klass.assigned.each do |ad|
	  if ad.assignment.grade_category==self && !ad.hide_grades?
		s = ad.get_user_submission(user)
		if s && s.graded?
		  sum += s.get_adjusted_grade_points
		end
	  end
	end
	
	return sum
  end
  
  
  def get_category_grade_percent(klass,user)
    max = get_category_max_points(klass,user)
	if max==0
	  1
	else
      get_category_grade_points(klass,user)/max
	end
  end
  
  private
  
  def class_or_course
    unless klass_id.blank? ^ course_id.blank?
      errors.add(:base, "Category must be part of a class or course!")
    end
  end
  
end
