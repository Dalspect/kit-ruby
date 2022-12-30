class SshKey < ApplicationRecord
  belongs_to :user
  
  validates :key, presence: true
  validates :label, presence: true
  
  after_save {SshKey.refresh_repo_keys}
  after_destroy {SshKey.refresh_repo_keys}
  
  def self.refresh_repo_keys
    #Clear old keys folder
	#Write u(number).pub file for each user's keys
	#push authorization repo
	
	#Use first ssh key as a semophore lock
	#There are more complicated ways to do this, but in the off case that whoever has the first key in the table tries to delete it they can stand to wait a few seconds.
	if SshKey.first
	SshKey.first.with_lock do
	  
	  #Delete old keys folder
	  if Dir.exist?("/var/www/KIT/gitauth/auth/keydir")
		FileUtils.remove_dir("/var/www/KIT/gitauth/auth/keydir")
	  end
	  
	  #Make new folder
	  Dir.mkdir("/var/www/KIT/gitauth/auth/keydir")
	  
	  #TODO add server user's keys
	  FileUtils.cp("/var/www/KIT/gitauth/auth.pub","/var/www/KIT/gitauth/auth/keydir/auth.pub")
	  
	  #Add keys from database
	  User.all.each do |u|
	    File.open("/var/www/KIT/gitauth/auth/keydir/u"+u.id.to_s+".pub","w") do |f|
		  #One file can have multiple keys as long as they are on new lines
		  u.ssh_keys.each do |k|
		    f.write(k.key)
			f.write("\n")
		  end
		end
	  end
	  
	  
	  #Push authentication repo
	  g = Git.open("/var/www/KIT/gitauth/auth")
	  g.add(all: true)
	  
	  begin
	    g.commit("Keys refreshed.")
		g.push
		#Push worked
	  rescue Git::GitExecuteError => e
		#Push failed for some reason, probably because nothing actually changed on this refresh_repo_authorizations
		Rails.logger.debug("\n\nWARNING: Git repository refresh failed: ")
		Rails.logger.debug(e.message)
	  end
	end
  end
    return "works"
  end

end
