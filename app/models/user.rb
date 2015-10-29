class User < ActiveRecord::Base
  include Activable
  include Roleable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one  :admin_user
  has_many :actors
  has_many :actor_micros
  has_many :actor_mesos
  has_many :actor_macros

  def name
    "#{firstname} #{lastname}"
  end

  def self.filter_users(filters)
    actives   = filters[:active]['true']  if filters[:active].present?
    inactives = filters[:active]['false'] if filters[:active].present?

    users = if actives.present?
              filter_actives
            elsif inactives.present?
              filter_inactives
            else
              all
            end
    users
  end
end
