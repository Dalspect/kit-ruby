class Assignment < ApplicationRecord
  belongs_to :klass, optional: true
  belongs_to :course, optional: true
  belongs_to :grade_category, optional: true
  belongs_to :files_repo, class_name: "Repo", dependent: :destroy
  belongs_to :template_repo, class_name: "Repo", optional: true, dependent: :destroy
  
  has_many :problems, dependent: :destroy
  has_many :assigned, dependent: :destroy
  
  enum assignment_type: [:student_file, :student_repo, :professor_file, :grade_only]
  
  enum file_or_link: [:upload_files_only, :provide_urls_only, :both]
  
  
  validates :assignment_type, :presence => true
  validates :title, :presence => true
  
  validate :class_or_course
  
  validates :file_limit, presence: true, numericality: {greater_than: 0}
  
  def get_point_value
    sum = 0
	self.problems.each do |p|
	  sum += p.points
	end
	return sum
  end

  def is_valid_filetype?(fname)
    if(!permitted_filetypes || permitted_filetypes.empty?)
	  #Must have a file type
	  return fname.include?(".")
	else
	  ext = fname.split(".")[-1]
	  
	  permitted_filetypes.gsub(/[^\w\,]/,'').split(",").each do |type|
	    if ext==type
		  return true
		end
	  end
	  
	  return false
	  
	end
  end
  
  def clear_grade_cache
    self.assigned.each do |s|
	  s.clear_grade_cache
	end
  end
  
  def student_responsible?
    self.student_file? || self.student_repo?
  end
  
  def incomplete_possible?
    self.student_repo?
  end
  
  def has_uploaded_files?
    self.student_file? || self.professor_file?
  end
  
  def can_edit?(user)
    if self.klass
	  return self.klass.is_class_admin?(user)
    else
	  #Assignment belongs to course
	  return self.course.department.is_department_professor?(user)
	end
  end
  
  private

  def class_or_course
    unless klass_id.blank? ^ course_id.blank?
      errors.add(:base, "Assignment must be part of a class or course!")
    end
  end
  
end