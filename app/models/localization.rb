class Localization < ActiveRecord::Base
  include Activable

  belongs_to :user, touch: true
  
  has_many :actor_localizations, foreign_key: :localization_id
  has_many :actors, through: :actor_localizations, dependent: :destroy
  has_many :action_localizations, foreign_key: :localization_id
  has_many :actions, through: :action_localizations, dependent: :destroy

  validates :long, presence: true
  validates :lat, presence: true

  def actor_macros
    actors.where(type: 'ActorMacro')
  end

  def actor_mesos
    actors.where(type: 'ActorMeso')
  end

  def actor_micros
    actors.where(type: 'ActorMicro')
  end

  def action_macros
    actions.where(type: 'ActionMacro')
  end

  def action_mesos
    actions.where(type: 'ActionMeso')
  end

  def action_micros
    actions.where(type: 'ActionMicro')
  end
end
