class Action < ActiveRecord::Base
  include Activable

  belongs_to :user

  has_many :action_relations_as_parent, class_name: 'ActionRelation', foreign_key: :parent_id
  has_many :action_relations_as_child, class_name: 'ActionRelation', foreign_key: :child_id

  has_many :children, through: :action_relations_as_parent, dependent: :destroy
  has_many :parents, through: :action_relations_as_child, dependent: :destroy

  has_many :action_localizations, foreign_key: :action_id
  has_many :localizations, through: :action_localizations, dependent: :destroy

  has_many :action_actor_relations, foreign_key: :action_id
  has_many :actors, through: :action_actor_relations, dependent: :destroy

  has_and_belongs_to_many :categories

  before_update :deactivate_dependencies, if: '!active and active_changed?'

  scope :not_macros_parents, -> (child) { where(type: 'ActionMacro').
                                          where('id NOT IN (SELECT parent_id FROM action_relations WHERE child_id=?)', 
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActionMeso').
                                          where('id NOT IN (SELECT parent_id FROM action_relations WHERE child_id=?)', 
                                          child.id) }
  
  validates :type, presence: true
  validates :name, presence: true

  def self.filter_actions(filters)
    actives   = filters[:active]['true']  if filters[:active].present?
    inactives = filters[:active]['false'] if filters[:active].present?

    actions = if actives.present?
                filter_actives
              elsif inactives.present?
                filter_inactives
              else
                all
              end
    actions
  end

  def membership_date(action, parent)
    relation   = action_relations_as_parent.get_dates(action, parent)
    start_date = relation.first.blank? ? 'now' : relation.first
    end_date   = relation.last.blank? ? 'now' : relation.last

    # Literal date format
    "from: #{start_date} - to: #{end_date}"
  end

  def macros_parents
    parents.where(type: 'ActionMacro')
  end

  def mesos_parents
    parents.where(type: 'ActionMeso')
  end

  def micros_parents
    parents.where(type: 'ActionMicro')
  end

  def macros
    children.where(type: 'ActionMacro')
  end

  def mesos
    children.where(type: 'ActionMeso')
  end

  def micros
    children.where(type: 'ActionMicro')
  end

  def actor_macros
    actors.where(type: 'ActorMacro')
  end

  def actor_mesos
    actors.where(type: 'ActorMeso')
  end

  def actor_micros
    actors.where(type: 'ActorMicro')
  end

  def self.types
    %w(ActionMacro ActionMeso ActionMicro)
  end

  def macro?
    type.include?('ActionMacro')
  end

  def meso?
    type.include?('ActionMeso')
  end

  def micro?
    type.include?('ActionMicro')
  end

  def micro_or_meso?
    type.include?('ActionMicro') || type.include?('ActionMeso')
  end

  def localizations?
    localizations.any?
  end

  def categories?
    categories.any?
  end

  def startdate
    start_date.to_date if start_date.present?
  end

  def enddate
    end_date.to_date if end_date.present?
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
