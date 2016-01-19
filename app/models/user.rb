class User < ActiveRecord::Base
  include Activable
  include Roleable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :check_authentication_token
  before_save :set_token_expiration

  has_one  :admin_user
  # Actors
  has_many :actors
  has_many :actor_micros
  has_many :actor_mesos
  has_many :actor_macros
  has_many :actor_relations

  # Acts
  has_many :acts
  has_many :act_micros
  has_many :act_mesos
  has_many :act_macros
  has_many :act_relations

  has_many :act_actor_relations
  has_many :localizations
  has_many :comments
  has_many :indicators
  has_many :act_indicator_relations
  has_many :measurements
  has_many :units

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

  def check_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def token_expired?
    DateTime.now >= token_expires_at
  end

  private

    def deactivate_dependencies
      actors.filter_actives.each do |actor|
        unless actor.deactivate
          return false
        end
      end

      acts.filter_actives.each do |act|
        unless act.deactivate
          return false
        end
      end

      localizations.filter_actives.each do |localization|
        unless localization.deactivate
          return false
        end
      end
    end

    def generate_authentication_token
      loop do
        auth_key = Devise.friendly_token[0,20]
        break auth_key unless User.where(authentication_token: auth_key).first
      end
    end

    def set_token_expiration
      self.token_expires_at = DateTime.now + 120.minutes
    end
end
