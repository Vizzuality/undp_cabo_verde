class Actor < ActiveRecord::Base
  include Activable

  belongs_to :user

  has_many :actor_relations_as_parent, class_name: 'ActorRelation', foreign_key: :parent_id
  has_many :actor_relations_as_child, class_name: 'ActorRelation', foreign_key: :child_id

  has_many :children, through: :actor_relations_as_parent, dependent: :destroy
  has_many :parents, through: :actor_relations_as_child, dependent: :destroy

  has_many :actor_localizations, foreign_key: :actor_id
  has_many :localizations, through: :actor_localizations, dependent: :destroy

  has_many :act_actor_relations, foreign_key: :actor_id
  has_many :acts, through: :act_actor_relations, dependent: :destroy

  has_many :comments, as: :commentable
  
  # Categories
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :organization_types,     -> { where(type: 'OrganizationType')    }, class_name: 'Category'
  has_and_belongs_to_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') }, class_name: 'Category'
  has_and_belongs_to_many :other_domains,          -> { where(type: 'OtherDomain')         }, class_name: 'Category'

  before_update :deactivate_dependencies, if: '!active and active_changed?'
  
  validates :type, presence: true
  validates :name, presence: true
  
  # Begin scopes
  scope :not_macros_parents, -> (child) { where(type: 'ActorMacro').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)', 
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActorMeso').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)', 
                                          child.id) }
                                          
  scope :last_max_update,    -> { maximum(:updated_at).to_time.iso8601 }
  scope :recent,             -> { order('updated_at DESC')             }
  # End scopes

  def self.types
    %w(ActorMacro ActorMeso ActorMicro)
  end

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

  def membership_date(actor, parent)
    relation   = actor_relations_as_parent.get_dates(actor, parent)
    start_date = relation.first.blank? ? 'now' : relation.first
    end_date   = relation.last.blank? ? 'now' : relation.last

    # Literal date format
    "from: #{start_date} - to: #{end_date}"
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

  def act_macros
    acts.where(type: 'ActMacro')
  end

  def act_mesos
    acts.where(type: 'ActMeso')
  end

  def act_micros
    acts.where(type: 'ActMicro')
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

  def meso_or_macro?
    type.include?('ActorMeso') || type.include?('ActorMacro')
  end

  def localizations?
    localizations.any?
  end

  def categories?
    categories.any?
  end

  def comments?
    comments.any?
  end

  def underscore
    to_s.underscore
  end

  def updated
    updated_at.to_s
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

      comments.filter_actives.each do |comment|
        unless comment.deactivate
          return false
        end
      end
    end
end
