class AdminUser < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id, touch: true

  delegate :firstname, :lastname, :name, :email, :institution, :active, :actors, :acts, :indicators, :measurements, :units, :comments, to: :user
  validates :user_id, presence: true, uniqueness: true
end