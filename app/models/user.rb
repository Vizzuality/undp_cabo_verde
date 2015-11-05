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
  has_many :actor_micro_mesos
  has_many :actor_micro_macros
  has_many :actor_meso_macros
  has_many :localizations

  before_update :deactivate_dependencies, if: '!active and active_changed?'

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

  private
    def deactivate_dependencies
      actors.filter_actives.each do |actor|
        unless actor.deactivate
          return false
        end
      end

      localizations.filter_actives.each do |localization|
        unless localization.deactivate
          return false
        end
      end
    end
end
