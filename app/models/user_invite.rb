class UserInvite < ApplicationRecord
  
  validates :email, presence: true, uniqueness: true
  before_save :downcase_email
  
  has_many :user_klass_invites, dependent: :destroy
  
	
	
	
  
  private
	
  def downcase_email
	self.email.downcase!
  end
	
	
end
