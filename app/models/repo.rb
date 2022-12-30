class Repo < ApplicationRecord
	
	
	has_one :course
	has_one :klass
	has_one :assigned
	has_one :assignment_files, class_name: "Assignment", foreign_key: "files_repo"
	has_one :assignment_template, class_name: "Assignment", foreign_key: "template_repo"
	has_one :submission
	has_one :department
	
	require 'git'
	
    after_destroy {Repo.refresh_repo_authorizations}
	after_destroy :delete_repo_files
	
	def self.refresh_repo_authorizations
	  $need_repo_refresh = true
	end
	
	def self.do_repository_refresh!
	  #Regenerate repo authorization file
	  #SSH keys are regenerated by the function in ssh_key.rb
	  
	  #Use first ssh key as a semophore lock
	  #There are more complicated ways to do this, but in the off case that whoever has the first key in the table tries to delete it they can stand to wait a few seconds.
	  if SshKey.first
	    SshKey.first.with_lock do
		
		  # Hash with key=id and value of a hash with :read and :write keys,
		  # each of which is an array of users with access
		  reps = {}
		  Repo.all.each do |r|
			reps[r.id] = {read: [], write: []}
		  end
		  
		  # Figure out who can access which repos
		  kit_admins = User.where(admin: true).map{|u| u.id}
		  Department.includes(:courses, :repo, :department_professors).each do |d|
		    dep_profs = kit_admins | d.department_professors.where(admin: false).map{|dp| dp.user.id}
			dep_admins = kit_admins | d.department_professors.map{|dp| dp.user.id}
			
			reps[d.repo.id][:write] = dep_profs
			
			d.courses.each do |c|
			  reps[c.repo.id][:write] = dep_profs
			  
			  c.assignment.each do |a|
			    reps[a.files_repo.id][:write] = dep_profs
				if a.template_repo
				  # Write 
				  reps[a.template_repo.id][:write] = dep_profs
				  
				  # Graders can also clone the template
				  #reps[a.template_repo.id][:read] = a.assigneds.map{|ad| ad.assigned_graders.map{|g| g.user.id}}.flatten
				end
			  end
			  
			  c.klass.each do |k|
			    klass_admins = dep_admins | k.professors.map{|p| p.user.id}
			    reps[k.repo.id][:write] = klass_admins
				
				k.assignment.each do |a|
			      reps[a.files_repo.id][:write] = dep_profs
				  
				  if a.template_repo
				    # Write 
				    reps[a.template_repo.id][:write] = dep_profs
				  end
				end
				
				k.assigned.each do |ad|
				  if ad.repo
				    graders = klass_admins | ad.assigned_graders.map{|ag| ag.user.id}
				    reps[ad.repo.id][:write] = klass_admins | graders
				  end
				  
				  if ad.assignment.student_repo?
				    graders = klass_admins | ad.assigned_graders.map{|ag| ag.user.id}
					
					reps[ad.assignment.template_repo.id][:read] |= graders
					
					ad.submissions.each do |s|
				      if s.repo
					    reps[s.repo.id][:write] = klass_admins | graders | s.contributors.map{|cont| cont.user.id}
					  end
					end
				  end
				  
				end
				
			  end
			end
			
		  end
		  
		  File.open("/var/www/KIT/gitauth/auth/gitosis.conf","w") do |f|
	        f.write("# Kit-Gitosis Repository Authorizations \n# Please do not edit manually as your changes will be overwritten.\n\n\n[group auth]\nmembers = auth\nwritable = gitosis-admin \n\n\n")
		    
			reps.each do |id, u|
			  
			  unless u[:write].empty?
				f.write("[group write"+id.to_s+"]\n")
				f.write("members = "+u[:write].map{|u| "u"+u.to_s}.join(" ")+"\n")
				f.write("writable = r"+id.to_s)
			  
				f.write("\n\n")
			  end
			  
			  unless u[:read].empty?
				f.write("[group read"+id.to_s+"]\n")
				f.write("members = "+u[:read].map{|u| "u"+u.to_s}.join(" ")+"\n")
				f.write("readonly = r"+id.to_s)
			  
				f.write("\n\n")
			  end
			
		    end
		  end
		  
		  #Push authentication repo
		  g = Git.open("/var/www/KIT/gitauth/auth")
		  g.add(all: true)
		  g.push
		  
		  begin
			g.commit("Repos refreshed.")
			g.push
			#Push worked
		  rescue Git::GitExecuteError => e
			#Push failed for some reason, probably because nothing actually changed on this refresh_repo_authorizations
			Rails.logger.warn("\n\nWARNING: Git repository refresh failed: ")
			Rails.logger.warn(e.message)
		  end
		  
		end
	  end
	end
	
	
	def init_files_repository
	  self.with_lock do
	    #Start with folders: professor, grader, student
	    
		gw = Git.init(get_repository_write_directory)
		
	    Dir.mkdir(get_repository_write_directory+"professor")		
	    gitignore = File.new(get_repository_write_directory+"professor/.gitignore",mode: "w")
		gitignore.puts("#Ironically, the purpose of this file is to make git not ignore this directory.")
		gitignore.close

		Dir.mkdir(get_repository_write_directory+"grader")		
	    gitignore = File.new(get_repository_write_directory+"grader/.gitignore",mode: "w")
		gitignore.puts("#Ironically, the purpose of this file is to make git not ignore this directory.")
		gitignore.close
		
		Dir.mkdir(get_repository_write_directory+"student")
	    gitignore = File.new(get_repository_write_directory+"student/.gitignore",mode: "w")
		gitignore.puts("#Ironically, the purpose of this file is to make git not ignore this directory.")
		gitignore.close
		
	    gw.add(get_repository_write_directory+"professor")
		gw.add(get_repository_write_directory+"grader")
		gw.add(get_repository_write_directory+"student")
		
	    gw.commit("Initialized by Kit server")
		
		Git.clone(get_repository_write_directory, get_repository_server_directory, bare: true)
		
	    close_writeable_repository
		
		#Create readable repo copy and set post-update hook to keep it up to date
		set_post_update_hook
	    
		fix_bare_permissions
		fix_readable_permissions
	   
	  end
	  Repo.refresh_repo_authorizations
	end
	
	
	def init_submissions_repository
	  self.with_lock do
	    #These repos hold submitted files
	    #Unsorted folder for bulk uploading
		
		gw = Git.init(get_repository_write_directory)
		
	    Dir.mkdir(get_repository_write_directory+"unsorted")		
	    gitignore = File.new(get_repository_write_directory+"unsorted/.gitignore",mode: "w")
		gitignore.puts("#Ironically, the purpose of this file is to make git not ignore this directory.")
		gitignore.close
		
	    gw.add(get_repository_write_directory+"unsorted")
		
	    gw.commit("Initialized by Kit server")
		
		Git.clone(get_repository_write_directory, get_repository_server_directory, bare: true)
		
	    close_writeable_repository
		
		#Create readable repo copy and set post-update hook to keep it up to date
		set_post_update_hook
		
		#Fix file permissions and set to shared mode
		fix_bare_permissions
		fix_readable_permissions
	    
	  end
	  Repo.refresh_repo_authorizations
	end
	
	
	def init_blank_repository
	  self.with_lock do
	    #These repos start out blank and do not have a readable clone
	  
	    gw = Git.init(get_repository_write_directory)
	  
	    g = Git.clone(get_repository_write_directory, get_repository_server_directory, bare: true)
	  
	    close_writeable_repository
		
		#Fix permissions and set shared mode
		fix_bare_permissions

	  end
	  Repo.refresh_repo_authorizations
	end
	
	
	def init_submission_repository(template)
	  self.with_lock do
	    #Clone the passed template repository
	  
	    g = Git.clone(template.get_repository_server_directory, get_repository_server_directory, bare: true)
		
		#Fix permissions and set shared mode
		fix_bare_permissions
	    
		end
	  Repo.refresh_repo_authorizations
	end
	
	
	def copy_files_repository(source)
	  self.with_lock do
	    #Clone the passed template repository
	  
	    g = Git.clone(source.get_repository_server_directory, get_repository_server_directory, bare: true)
		
		#Create readable repo copy and set post-update hook to keep it up to date
		set_post_update_hook
	    
		fix_bare_permissions
		fix_readable_permissions
	    
	  end
	end
	
	def copy_template_repository(source)
	  self.with_lock do
	    #Clone the passed source repository
	  
	    g = Git.clone(source.get_repository_server_directory, get_repository_server_directory, bare: true)
		
		#Fix permissions and set shared mode
		fix_bare_permissions
	    
		end
	  Repo.refresh_repo_authorizations
	end
	
	
	def add_file(dir, file_name, file_data, commit_message)
	  self.with_lock do
	    g = open_writeable_repository
		
		fulldir = 
		  get_repository_write_directory +
		  File::SEPARATOR +
		  dir.join(File::SEPARATOR) +
		  File::SEPARATOR +
		  file_name;
		
		File.open(fulldir,"wb") {|f| 
		  f.write(file_data)
		}
		
		g.add(all: true)
		g.commit(commit_message)
		g.push
		
		close_writeable_repository
	  end
	end
	
	def delete_file(dir, commit_message)
	  self.with_lock do
	    g = open_writeable_repository
	    
		fulldir = 
		  get_repository_write_directory +
		  File::SEPARATOR +
		  dir.join(File::SEPARATOR);
		  
		File.delete(fulldir)
		
		g.add(all: true)
		g.commit(commit_message)
		g.push
		
		close_writeable_repository
	  end
	end
	
	def add_directory(dir,name,commit_message)
	  self.with_lock do
	    g = open_writeable_repository
		
		fullpath = get_repository_write_directory+
		  File::SEPARATOR+
		  dir.join(File::SEPARATOR)+
		  File::SEPARATOR+
		  name;
		  
		Dir.mkdir(fullpath)
		
		gitignore = File.new(fullpath + File::SEPARATOR + ".gitignore",mode: "w")
		gitignore.puts("#Ironically, the purpose of this file is to make git not ignore this directory.")
		gitignore.close
		
		g.add(all: true)
		g.commit(commit_message)
		g.push
		
		close_writeable_repository
	  end
	end
	
	def delete_directory(dir,commit_message)
	  self.with_lock do
	    g = open_writeable_repository
		
		fulldir = get_repository_write_directory+File::SEPARATOR+dir.join(File::SEPARATOR)
		if Dir.exist?(fulldir)
		  FileUtils.remove_dir(fulldir, force: true)
		  
		  g.add(all: true)
		  g.commit(commit_message)
		  g.push
	    end
		
		close_writeable_repository
	  end
	end
	
	def get_repository_read_directory
	  #Returns the directory containing the readable version of the repository
	  #Only valid for file storage & file submission repositories
	  return "/var/www/KIT/readable-working-dirs/r"+self.id.to_s+"/"
	end
	
	def get_repository_server_directory
	  return "/var/www/KIT/gitosis/repositories/r"+self.id.to_s+".git"
	  #Note: this broke when an "/" was at the end
	end
	
	def test_reset_files
	  delete_repo_files
	end
	
	
  #Authorization checks for files repositories Only
  #All other types of repos with online edits shall be handled via the appropriate controller
  
  def can_view_files_repo?(user, dir)
    #Students can view student files, graders student and grader, professor all
	
	#Handle case of professor of a course class but not admin, they can read but not write so aren't included in "repo_admin?"
	if (self.course && (self.course.klass & user.get_professor_classes).any?)
	  return true
	elsif dir[0]=="professor"
	  return repo_admin?(user)
	elsif dir[0]=="grader"
	  return repo_admin?(user) || repo_grader?(user) 
	elsif dir[0]=="student"
	  return repo_admin?(user) || repo_grader?(user) || repo_student?(user)
	else
	  #Beginning of dir is something it shouldn't be
	  return false
	end
  end
  
  def can_edit_files_repo?(user, dir)
    #Only admins can write to files repos
	return repo_admin?(user)
  end

  
  def is_safe_directory?(dir)
	valid = true
	  
	dir.each do |s|
	  if (s!=s.gsub(/[^\w\-\.\ ]/,'_') || s[0]=='.')
		valid = false
	  end
	end
	  
	return valid
  end

  
  def fix_bare_permissions
	  FileUtils.chmod_R(02770, get_repository_server_directory)
	  g = Git.bare(get_repository_server_directory)
	  g.config('core.sharedRepository','group')
      g.config('receive.denyNonFastforwards','true')
      g.config('config.sharedRepository','true')
	end
	
	
	def fix_readable_permissions
	  FileUtils.chmod_R(02770, get_repository_read_directory)
	  g = Git.open(get_repository_read_directory)
	  g.config('core.sharedRepository','group')
      g.config('receive.denyNonFastforwards','true')
      g.config('config.sharedRepository','true')
	  g.config('core.filemode','false')
	end
  
  def bulk_upload(files, commit_message)
	self.with_lock do
	  g = open_writeable_repository
		
	  dir = get_repository_write_directory+File::SEPARATOR+"unsorted"+File::SEPARATOR
	  
	  files.each do |f|
	    
		if(is_safe_directory?([f.original_filename]))
		  
		  File.open(dir+f.original_filename,"wb") {|newf| 
		    newf.write(f.read)
		  }
		end
		
	  end
	  
	  g.add(all: true)
	  g.commit(commit_message)
	  g.push
		
	  close_writeable_repository
	end
  end
  
  def bulk_sort(files, commit_message, feedback, assigned)
    self.with_lock do
	
	# If an exception occurs anywhere in here, all the submissions/contributors created should be cancelled
	Assigned.transaction do
	
	  g = open_writeable_repository
		
	  basedir = get_repository_write_directory+File::SEPARATOR
	  dir = basedir+"unsorted"+File::SEPARATOR
	  
	  changed = false
	  
	  # Store newly created submissions so we have them for additional files
	  # Looking up from database they won't appear because of transaction/caching
	  submissions = []
	  
	  files.each do |f, op|
	    
		if(is_safe_directory?([f]))
		  
		  if(op.to_i==-1)
		    # Leave file alone, stay unsorted
		  elsif(op.to_i==-2)
		    # Delete this file
			File.delete(dir+f)
			changed = true
		  elsif(op.to_i>0)
		    u = User.find(op.to_i)
			
			# Check if submission for this user already loaded
			s = submissions.select{|s, id| id==op.to_i}.first
			unless s
			  # Does this user already have a submission?
			  s = assigned.get_user_submission(u)
			  
			  unless s
			    # No submission yet
				s = Submission.create!(assigned: self.assigned, professor_uploaded: true)
			    Contributor.create!(submission: s, user: u)
				
				submissions.push([s, op.to_i])
			  end
			else
			  s = s[0]
			end

		    # Create submission
			#u = User.find(op.to_i)
			#s = Submission.create!(assigned: self.assigned, professor_uploaded: true)
			#Contributor.create!(submission: s, user: u)
			
			# Move file
		    fname = u.get_full_preferred_name.gsub(" ","-").gsub(/[^\w]/,'') + "_" + 
			  f.gsub(/[^\w\-\.]/,'_')+"_"
			
			if feedback
			  fname += "f"
			else
			  fname += "s"
			end
		
		    fname += s.id.to_s+"."+f.split(".")[-1].gsub(/[^\w\-]/,'_')
			
			FileUtils.mv(dir+f, basedir+fname)
			
			changed = true
		  end
		  
		end
		
	  end
	  
	  if(changed)
	    g.add(all: true)
	    g.commit(commit_message)
	    g.push
	  end
	  
	  close_writeable_repository
	end
	end
  end
  
  private
  def repo_admin?(user)
    if self.department
	  # Department professor/admin
	  return self.department.is_department_professor?(user)
    elsif self.course
	  # Department professor/admin
	  return self.course.department.is_department_professor?(user)
	elsif self.klass
	  # Only a class admin
	  return self.klass.is_class_admin?(user)
	elsif self.assignment_files
	  if self.assignment_files.course
	    # If course assignment, department professor
		return self.assignment_files.course.department.is_department_professor?(user)
	  else
	    # Else if class assignment, class admin
		return self.assignment_files.klass.is_class_admin?(user)
	  end
	else
	  #Some other kind of repo, shouldn't be here
	  return false
	end
  end
  
  def repo_grader?(user)
    if self.department
	  # grader in at least one class in department
	  return user.get_grader_classes.map{|c| c.course.department}.include?(self.department)
	elsif self.klass
	  #grader for this class
	  return user.get_grader_classes.include?(self.klass)
	elsif self.course
	  #grader for at least one class of the course
	  return !(self.course.klass & user.get_grader_classes).empty?
	elsif self.assignment_files
	  #grader on at least one assigned of the assignment
	  self.assignment_files.assigned.each do |ad|
		if ad.can_grade?(user)
		  return true
	    end
	  end
	  return false
	else
	  #Not a files repo?
	  return false
	end
  end
  
  def repo_student?(user)
    if self.department
	  # In any class in department
	  return user.get_student_classes.map{|c| c.course.department}.include?(self.department)
	elsif self.klass
	  #In class
	  return user.get_student_classes.include?(self.klass)
	elsif self.course
	  #In a class of this course
	  return !(user.get_student_classes & self.course.klass).empty?
	elsif self.assignment_files
	  #In a class with this assignment assigned
	  self.assignment_files.assigned.each do |ad|
		if user.get_student_classes.include?(ad.klass)
		  return true
		end
	  end
	  return false
	else
	  #Not a files repo?
	  return false
	end
  end

  
  
	def delete_repo_files
		# Erase repo from gitosis server and working directory
		
		if Dir.exist?(get_repository_server_directory)
		  FileUtils.remove_dir(get_repository_server_directory, force: true)
		end
		
		if Dir.exist?(get_repository_read_directory)
		  FileUtils.remove_dir(get_repository_read_directory, force: true)
		end
		
		if Dir.exist?(get_repository_write_directory)
		  FileUtils.remove_dir(get_repository_write_directory, force: true)
		end
	end
	
	def open_writeable_repository
	  #Make sure directory doesn't exist
	  #Clone bare repo into write directory
	  
	  close_writeable_repository
	  
	  return Git.clone(get_repository_server_directory, get_repository_write_directory)
	  
	end
	
	def get_repository_write_directory
	  return "/var/www/KIT/writable-working-dirs/r"+self.id.to_s+"/"
	end
	
	
	def push_writeable_repository(g)
	  begin
		g.push
		#Push worked
		return true
	  rescue Git::GitExecuteError
		#Push failed for some reason, probably someone else pushed before we did
		return false
	  end	
	end
	
	def close_writeable_repository
	  #Delete the temporary write repository
	  if Dir.exist?(get_repository_write_directory)
		FileUtils.remove_dir(get_repository_write_directory, force: true)
	  end
	end
	
	POST_UPDATE_HOOK = 
'#!/bin/sh
#
# This hook updates the read-only working copy of a repository for the Kit platform.
# This hook should appear in every file storage and file submission repository.

unset GIT_DIR
REPO_DIR_NAME=$(basename "$PWD")
REPO_DIR_NAME=${REPO_DIR_NAME%.git}
exec git -C /var/www/KIT/readable-working-dirs/"$REPO_DIR_NAME"/ pull origin master'
	
	def set_post_update_hook
	  #Adds the post-update hook to the server repository
	  #This should be done for file submission and file storage repositories
	  
	  #Create blank readable repository
	  g = Git.clone(get_repository_server_directory, get_repository_read_directory)
	  
	  #Creates FETCH_HEAD, which doesn't obey shared repo settings and gets generated with 644 on first pull
	  #This way it exists for fix_readable_permissions to change
	  g.pull
	  
	  #Write hook file
	  hook = File.new(get_repository_server_directory+"/hooks/post-update",mode: "w", perm: 0550)
	  hook.puts POST_UPDATE_HOOK
	  hook.close
	end
	
end
