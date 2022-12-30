class ApplicationController < ActionController::Base
	
	#----------------------------------------------------------------
	# URL Helpers
	#----------------------------------------------------------------
	
	#Get url for a repository using the website's url
	def get_repo_url(r)
		"git@"+request.base_url.gsub("http://","").gsub("https://","")+":r"+r.id.to_s
	end
	helper_method :get_repo_url
	
	#Used for back/destroy buttons for things that could have a course or class parent
	#def get_class_or_course_url(c)
	#  if c.course
	#    course_path(c.course)
	#  elsif c.klass
	#    klass_path(c.klass)
	#  end
	#end
	#helper_method :get_class_or_course_url
	
	#--------------------------------------------------------------
	# Authentication helpers
	#--------------------------------------------------------------
	
	#Get current user if not already defined, nil if no user_id in session cookie
	def current_user
	  if session[:user_id]
	    @current_user ||=  User.find(session[:user_id])
	  end
	end
	helper_method :current_user
	
	#Make sure user is logged in
	#This MUST be called before any other authentication!
	def authenticate_logged_in!
	  unless current_user
	    redirect_to login_url
      else
	  
	    # Check that session is not expired
	    # TODO
	  
	    # Make sure account has not been disabled
	    if current_user.disabled?
	      session[:user_id] = nil
		 
		  redirect_to login_url, alert: "Your account has been disabled. Please contact your system administrator."
	    end
	  end
	end
	helper_method :authenticate_logged_in!
	
	#Checks if user is admin- if not or logged out, redirect to root url
	def authenticate_kit_admin!
	  unless current_user.admin?
	    #root_url redirects to login if !current_user
	    redirect_to root_url
      end
	end
	helper_method :authenticate_kit_admin!
	
	#Checks if user is admin of a class (global admin, dep admin, or professor)
	def authenticate_class_admin! (klass)
	  unless klass.is_class_admin?(current_user)
	    redirect_to root_url
	  end
	end
	
	def authenticate_department_admin!(dep)
	  unless dep.is_department_admin?(current_user)
	    redirect_to root_url
	  end
	end
	
	def authenticate_department_professor!(dep)
	  unless dep.is_department_professor?(current_user)
	    redirect_to root_url
	  end
	end
	
	#Checks if user is grader of a class (global admin, dep admin, professor or grader)
	def authenticate_class_grader! (klass)
	  unless ( klass.is_class_admin?(current_user) ||
	   current_user.graders.exists?(klass: klass) )
	    redirect_to root_url
	  end
	end
	
	#Check if grader is authorized to grade an assignment.
	#Also checks if class grader
	def authenticate_assigned_grader! (assigned)
	  unless assigned.can_grade?(current_user)
	    redirect_to root_url
	  end
	end
	
	#Checks if user is a student of a class
	def authenticate_class_student! (klass)
	  unless (current_user.students.exists?(klass: klass))
	    redirect_to root_url
	  end
	end
	
	#Checks if user has any role with class
	def authenticate_class_member! (klass)
	  unless ( klass.is_class_admin?(current_user) ||
	   current_user.graders.exists?(klass: klass) ||
	   current_user.students.exists?(klass: klass))
	    redirect_to root_url
      end
	end
	
	#Checks if user has permission to edit assignment
	def authenticate_assignment_editor! (assignment)
	  unless assignment.can_edit?(current_user)
	    redirect_to root_url
	  end
	end
	
	#------------------------------------------------------
	# Repository refresh mechanics
	#------------------------------------------------------
	
	# A global variable is used to indicate if a repo refresh is needed
	# This prevents the refresh from happening more than once
	# Global variable is shared between requests but not threads
	
	def reset_repository_refresh_flag
	  $need_repo_refresh = false
	end
	before_action :reset_repository_refresh_flag
	
	def check_repository_refresh
	  if $need_repo_refresh
	    Repo.do_repository_refresh!
	  end
	end
	after_action :check_repository_refresh
	
	
	#-------------------------------------------------------
	# Grade cache regeneration & graded notification
	#-------------------------------------------------------
	
	# Solving issues with grade cache getting bad data from being re-cached in same request due to graded notifications
	# $recalculate_grade_cache is a hash with key=submission id, value=old cached grade
	
	def reset_check_graded_notification
	  $check_if_graded_for_notification = []
	end
	before_action :reset_check_graded_notification
	
	def check_graded_notification
	  # If it is possible for a student to need notification that their work is graded,
	  # then check now that all other changes have been made
	  
	  $check_if_graded_for_notification.uniq.each do |sid|
	    if Submission.exists?(sid)
		  Submission.find(sid).notify_if_graded
		end
	  end
	end
	after_action :check_graded_notification
	
	#---------------------------------------------------
	# Visual
	#---------------------------------------------------
	
	def get_color_for_grade(grade)
	
	
	  red = 0
	  green = 0
	  blue = 0
	  
	  if grade < 0.5
		red = 255
	  elsif grade < 0.75
		red = 255
		green = (grade-0.5)*4 * 255
	  elsif grade <= 1.0
	    green = 255
		red = 255 - (grade - 0.75) * 4 * 255
	  else
	    green = 255
	  end
	  
	  return "rgb("+red.to_s+","+green.to_s+","+blue.to_s+")"
	end
	helper_method :get_color_for_grade
	
	#------------------------------------------------
	# Next/Previous Sumbission
	# (Moved here from graded_problems_controller so it can be used on the submission grade page)
	# Currently based on ID, though this should change to something like the date turned in to better handle repos
	#------------------------------------------------
	
	# Get the submission after this one
	# nil if none remain
	def get_next_submission_from(current_sub)
	  subms = current_sub.assigned.submissions
		  .where("id > ?",current_sub.id)
	  unless subms.select{|s| s.contributors.any?}.empty?
	    return subms.order(id: :asc).select{|s| s.contributors.any?}.first
	  else
	    return nil
	  end
	end
	helper_method :get_next_submission_from
	
	#Get submission before this one
	#nil if none remain
	def get_previous_submission_from(current_sub)
	  subms = current_sub.assigned.submissions
		  .where("id < ?",current_sub.id)
	  unless subms.select{|s| s.contributors.any?}.empty?
	    return subms.order(id: :asc).select{|s| s.contributors.any?}.last
	  else
	    return nil
	  end
	end
	helper_method :get_previous_submission_from
	
end
