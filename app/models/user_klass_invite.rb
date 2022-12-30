class UserKlassInvite < ApplicationRecord
  belongs_to :klass
  belongs_to :user_invite
  
  validates :klass, uniqueness: {scope: :user_invite}
end
