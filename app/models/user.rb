class User < ActiveRecord::Base
  include Activable
  include Roleable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :timeoutable

  before_save :check_authentication_token

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
  has_many :favourites, -> { order(position: :asc) }, dependent: :destroy

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

  def check_authentication_token(destroy_true=nil)
    if self.authentication_token.blank?
      self.authentication_token = generate_authentication_token
      set_token_expiration
    elsif destroy_true.present?
      query = "UPDATE users SET authentication_token=null, token_expires_at=null WHERE id=#{self.id}"
      ActiveRecord::Base.connection.execute(query)
    end
  end

  def token_expired?
    token_expires_at.present? && DateTime.now >= token_expires_at unless remember_exists_and_not_expired?
  end

  def remember_exists_and_not_expired?
    return false unless respond_to?(:remember_created_at) && respond_to?(:remember_expired?)
    remember_created_at && !remember_expired?
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
      self.token_expires_at = DateTime.now + timeout_in
    end
end
