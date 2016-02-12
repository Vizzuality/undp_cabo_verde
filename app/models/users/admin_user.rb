class AdminUser < ActiveRecord::Base
  belongs_to :user, touch: true

  delegate :firstname, :lastname, :email, :institution, :active, to: :user
  validates :user_id, presence: true, uniqueness: true
end