class NotifyGraderRegradeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :assigned
  
  def remove_if_invalid
	
    valid = self.user.admin?
	
	valid |= self.user.department_professors.select{|p| !p.destroyed? && p.admin?}.map{|p| p.department.courses.map{|c| c.klass}}.flatten.include?(self.assigned.klass.course.department)
	
	valid |= self.user.professors.select{|p| !p.destroyed?}.map{|p| p.klass}.include?(self.assigned.klass)
	
	valid |= self.user.assigned_graders.select{|ag| !ag.destroyed?}.map{|g| g.assigned}.include?(self.assigned)
	
	unless valid
	  self.destroy
	end
  end
end
