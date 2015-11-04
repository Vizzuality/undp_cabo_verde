class Actor < ActiveRecord::Base
  include Activable

  belongs_to :user, touch: true

  has_many :actor_localizations, foreign_key: :actor_id
  has_many :localizations, through: :actor_localizations, dependent: :destroy

  validates :name, presence: true
  validates :type, presence: true

  def self.filter_actors(filters)
    actives   = filters[:active]['true']  if filters[:active].present?
    inactives = filters[:active]['false'] if filters[:active].present?

    actors = if actives.present?
               filter_actives
             elsif inactives.present?
               filter_inactives
             else
               all
             end
    actors
  end

  def self.types
    %w(ActorMacro ActorMeso ActorMicro)
  end

  def macro?
    type.include?('ActorMacro')
  end

  def meso?
    type.include?('ActorMeso')
  end

  def micro?
    type.include?('ActorMicro')
  end

  def micro_or_meso?
    type.include?('ActorMicro') || type.include?('ActorMeso')
  end

  def underscore
    to_s.underscore
  end
end
