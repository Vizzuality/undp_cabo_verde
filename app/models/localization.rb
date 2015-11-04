class Localization < ActiveRecord::Base
  has_many :actor_localizations, foreign_key: :localization_id
  has_many :actors, through: :actor_localizations, dependent: :destroy

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
end
