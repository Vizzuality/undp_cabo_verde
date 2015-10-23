class User < ActiveRecord::Base

  include Activable
  include Roleable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :admin_user

  def name
    "#{firstname} #{lastname}"
  end
  
end
