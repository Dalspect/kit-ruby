class Klass < ApplicationRecord
  belongs_to :course
  belongs_to :repo, dependent: :destroy
  
  has_many :assignment, dependent: :destroy
  has_many :professors, dependent: :destroy
  has_many :graders, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :grade_category, dependent: :destroy
  has_many :assigned, dependent: :destroy
  has_many :user_klass_invites, dependent: :destroy
  
  validates :semester, :presence => true
  
  
  def get_grade_categories
    if self.course
      self.course.grade_category
    else
	  self.grade_category
	end
  end
  
  def get_student_grade_percent(user)
    self.get_grade_categories.sum{|cat| cat.get_category_grade_percent(self,user)*cat.weight }
  end
  
  # Get gradebook as CSV format
  def gradebook_as_csv(assigneds)
    str = ""
	
	#Headers
	str += "Name,"
    self.get_grade_categories.each do |cat|
	  assigneds.select{|ad| ad.assignment.grade_category == cat}.each do |ad|
	    str += ad.assignment.title.gsub(",","") + "(/" + ad.get_adjusted_max_grade.to_s+")"
		
		if ad.hide_grades?
		  str+= " Not counted: Hidden from students!"
		end
		
	    str += ","
	  end
	  str += cat.title.gsub(",","") + " Total,"
	  str += cat.title.gsub(",","") + " Percent,"
	end
	
	str += "Total Grade\n"
    
	#Each student line
    self.students.map{|s| s.user}.sort_by{|u| u.get_full_real_name_reverse}.each do |u|
	  
	  str += u.get_full_name.gsub(",","") + ","
	  
	  self.get_grade_categories.each do |cat|
        assigneds.select{|ad| ad.assignment.grade_category == cat}.each do |ad|
		  if ad.get_user_submission(u) && ad.get_user_submission(u).graded?
		    str += ad.get_user_submission(u).get_adjusted_grade_points.to_s + ","
		  else
			str+="-,"
		  end
		end
		
		#Total grade in category
		str += cat.get_category_grade_points(self,u).to_s + "/" + cat.get_category_max_points(self,u).to_s + ","
		str += (cat.get_category_grade_percent(self,u)*100).to_s + "%,"
		
	  end
	  
	  #Total grade in class
	  str += self.get_student_grade_percent(u).to_s + "%\n"
	end
	
    return str
  end
  
  
  def is_class_admin?(user)
    if self.professors.find_by(user: user)
	  return true
	else
	  return self.course.department.is_department_admin?(user)
	end
  end
  
  
end
