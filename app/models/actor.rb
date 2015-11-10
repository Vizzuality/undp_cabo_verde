class Actor < ActiveRecord::Base
  include Activable

  belongs_to :user

  has_many :actor_relations_as_parent, class_name: 'ActorRelation', foreign_key: :parent_id
  has_many :actor_relations_as_child, class_name: 'ActorRelation', foreign_key: :child_id

  has_many :children, through: :actor_relations_as_parent, dependent: :destroy
  has_many :parents, through: :actor_relations_as_child, dependent: :destroy

  has_many :actor_localizations, foreign_key: :actor_id
  has_many :localizations, through: :actor_localizations, dependent: :destroy

  before_update :deactivate_dependencies, if: '!active and active_changed?'

  scope :not_macros_parents, -> (child) { where(type: 'ActorMacro').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)', 
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActorMeso').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)', 
                                          child.id) }

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

  def macros_parents
    parents.where(type: 'ActorMacro')
  end

  def mesos_parents
    parents.where(type: 'ActorMeso')
  end

  def micros_parents
    parents.where(type: 'ActorMicro')
  end

  def macros
    children.where(type: 'ActorMacro')
  end

  def mesos
    children.where(type: 'ActorMeso')
  end

  def micros
    children.where(type: 'ActorMicro')
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

  private
    def deactivate_dependencies
      localizations.filter_actives.each do |localization|
        unless localization.deactivate
          return false
        end
      end

      children.filter_actives.each do |child|
        unless child.deactivate
          return false
        end
      end
    end
end
