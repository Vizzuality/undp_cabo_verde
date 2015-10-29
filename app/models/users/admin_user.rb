class AdminUser < ActiveRecord::Base

  belongs_to :user, touch: true
  
  delegate :firstname, :lastname, :email, to: :user

  validates :user_id, presence: true, uniqueness: true

end