class Actor < ActiveRecord::Base
  include Activable
  include Localizable

  belongs_to :user, foreign_key: :user_id

  has_many :actor_relations_as_parent, class_name: 'ActorRelation', foreign_key: :parent_id
  has_many :actor_relations_as_child,  class_name: 'ActorRelation', foreign_key: :child_id

  has_many :children, through: :actor_relations_as_parent, dependent: :destroy
  has_many :parents,  through: :actor_relations_as_child,  dependent: :destroy

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
  has_and_belongs_to_many :operational_fields,     -> { where(type: 'OperationalField')    }, class_name: 'Category', limit: 1
  # For merged domains
  has_and_belongs_to_many :merged_domains,         -> { where(type: ['OtherDomain', 'SocioCulturalDomain']) }, class_name: 'Category', limit: 3

  accepts_nested_attributes_for :localizations,             allow_destroy: true
  accepts_nested_attributes_for :actor_relations_as_child,  allow_destroy: true, reject_if: :parent_invalid
  accepts_nested_attributes_for :actor_relations_as_parent, allow_destroy: true, reject_if: :child_invalid
  accepts_nested_attributes_for :act_actor_relations,       allow_destroy: true, reject_if: :action_invalid
  accepts_nested_attributes_for :other_domains,                                  reject_if: :other_domain_invalid, limit: 3

  after_create  :set_main_location,       if: 'localizations.any?'
  after_update  :set_main_location,       if: 'localizations.any?'
  before_update :deactivate_dependencies, if: '!active and active_changed?'

  validates :type,              presence: true
  validates :name,              presence: true
  validates :merged_domain_ids, presence: true

  validates_length_of :merged_domains, minimum: 1, maximum: 3

  # Begin scopes
  scope :not_macros_parents, -> (child) { where(type: 'ActorMacro').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)',
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActorMeso').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)',
                                          child.id) }

  scope :last_max_update,    -> { maximum(:updated_at)                     }
  scope :recent,             -> { order('updated_at DESC')                 }
  scope :meso_and_macro,     -> { where(type: ['ActorMeso', 'ActorMacro']) }
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

  def main_locations
    actor_localizations.main_locations
  end

  def actor_localizations_by_date(options)
    start_date = options['start_date'] if options['start_date'].present?
    end_date   = options['end_date']   if options['end_date'].present?

    actor_localizations.by_date(start_date, end_date)
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

    def parent_invalid(attributes)
      attributes['parent_id'].empty? || attributes['relation_type_id'].empty?
    end

    def child_invalid(attributes)
      attributes['child_id'].empty? || attributes['relation_type_id'].empty?
    end

    def action_invalid(attributes)
      attributes['act_id'].empty? || attributes['relation_type_id'].empty?
    end

    def other_domain_invalid(attributes)
      attributes['name'].empty?
    end

    def set_main_location
      if actor_localizations.main_locations.empty?
        actor_localizations.order(:created_at).first.update( main: true )
      end
    end
end
