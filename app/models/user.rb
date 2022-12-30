class User < ApplicationRecord
	
	# ------ Relations ----- #
    has_many :professors, dependent: :destroy
	has_many :students, dependent: :destroy
	has_many :graders, dependent: :destroy
	has_many :assigned_graders, dependent: :destroy
	has_many :contributors, dependent: :destroy
	has_many :extensions, dependent: :destroy
	has_many :past_contributors, dependent: :destroy
	has_many :notify_grader_new_submissions, dependent: :destroy
	has_many :department_professors, dependent: :destroy
	has_many :notify_grader_regrade_request, dependent: :destroy
	has_many :graded_problems, foreign_key: "grader_id", dependent: :nullify
	has_many :contributor_invites, dependent: :destroy
	has_many :submissions, through: :contributors
	has_many :ssh_keys, dependent: :destroy
	
	# ----- Rails+bcrypt password methods are included by this call ----- #
	has_secure_password
	
	# ----- Validations ----- #
	#validates :first_name, presence: true
	#validates :last_name, presence: true
	validates :email, presence: true, uniqueness: true
	
	validate :has_name_or_isnt_setup
	
	def has_name_or_isnt_setup
	  if set_up
	    if !first_name || first_name.empty? || !last_name || last_name.empty?
	      errors.add(:base,"First name and last name are required.")
		  return
		end
	  end
	end
	
	before_save :downcase_email
	
	
	# ----- Notifications callbacks ----- #
	after_save :check_submission_notifications
	
	
	# ----- User Invitations ------ #
	after_create :send_invite!
	
    def send_invite!
	  token = SecureRandom.hex(32)
	  
	  # Store account creation digest in password digest field
	  # They can't be used at the same time anyway!
	  self.reset_digest = Digest::SHA256.base64digest(token)
	  self.save!
	  
	  #Send email with token
	  AccountsMailer.invite_user_email(self, token).deliver_now
	  
    end
	
	# IMPORTANT: Accounts get a random password when they are first created.
	# This password cannot actually be used as the set_up boolean is false, which prevents logins
	# has_secure_password forbids not having a password, and using a default password would be dumb
	# if set_up ever stopped working
	def set_default_password
	  # Password isn't actually usable because we never share it
	  self.password = SecureRandom.hex(32)
	  self.password_confirmation = self.password
	end
	
	def valid_invite_token?(token)
	  return self.reset_digest &&  Digest::SHA256.base64digest(token)==self.reset_digest
	end
	
	# ----- Name methods ------- #
	
	# Preferred first name of user
	def get_preferred_first_name
	  unless self.set_up
	    return self.email
	  end
	  
	  if self.preferred_name && !self.preferred_name.empty?
	    self.preferred_name
	  else
	    self.first_name
	  end
    end
	
	# Preferred first name and last name of user
	def get_full_preferred_name
	  unless self.set_up
	    return self.email
	  end
	  
	  return self.get_preferred_first_name + " " + self.last_name
	end
	
	# Official first name and last name of user
	def get_full_real_name
	  unless self.set_up
	    return self.email
	  end
	  
	  return self.first_name + " " + self.last_name
	end
	
	# Official first/last name plus nickname
	def get_full_name
	  unless self.set_up
	    return self.email
	  end
	  
	  if self.preferred_name && !self.preferred_name.empty?
	    return self.first_name + " (" + self.preferred_name + ") "+self.last_name
	  else
	    return self.get_full_real_name
	  end
	end
	
	# Official name in reverse
	def get_full_real_name_reverse
	  unless self.set_up
	    return self.email
	  end
	  
	  return  self.last_name + ", " + self.first_name
	end
	
	
	# ------ Getters for role relations ------ #
	
	def get_student_classes
	  self.students.map {|s| s.klass}
	end
	
	def get_grader_classes
	  self.graders.map {|s| s.klass}
	end
	
	def get_professor_classes
	  self.professors.map {|s| s.klass}
	end
	
	
	# ------ Password Resets ------- #
	
	def new_password_reset_request!
	  token = SecureRandom.hex(32)
	  
	  self.reset_digest = Digest::SHA256.base64digest(token)
	  self.reset_expires = DateTime.current + 1.hours
	  self.save!
	  
	  #Send reset email with token
	  AccountsMailer.password_reset_email(self, token).deliver_now
	end
	
	def password_reset_valid?(token)
	  return self.reset_digest && self.reset_expires > DateTime.current && Digest::SHA256.base64digest(token)==self.reset_digest
	end
	
	
	# ------ Notifications ----- #
	
	def check_submission_notifications
	  self.notify_grader_new_submissions.each do |n|
	    n.remove_if_invalid
	  end
	end
	
	
	
	private
	
	def downcase_email
	  self.email.downcase!
	end
end
