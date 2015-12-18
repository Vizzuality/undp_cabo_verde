class Localization < ActiveRecord::Base
  include Activable

  belongs_to :user, touch: true
  
  has_many :actor_localizations, foreign_key: :localization_id
  has_many :actors, through: :actor_localizations, dependent: :destroy
  has_many :act_localizations, foreign_key: :localization_id
  has_many :acts, through: :act_localizations, dependent: :destroy
  has_many :indicator_localizations, foreign_key: :localization_id
  has_many :indicators, through: :indicator_localizations, dependent: :destroy

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

  def act_macros
    acts.where(type: 'ActMacro')
  end

  def act_mesos
    acts.where(type: 'ActMeso')
  end

  def act_micros
    acts.where(type: 'ActMicro')
  end
end
