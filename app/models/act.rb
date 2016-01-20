class Act < ActiveRecord::Base
  include Activable
  include Localizable

  monetize :budget_cents, allow_nil: true

  belongs_to :user, foreign_key: :user_id

  has_many :act_relations_as_parent, class_name: 'ActRelation', foreign_key: :parent_id
  has_many :act_relations_as_child,  class_name: 'ActRelation', foreign_key: :child_id

  has_many :children, through: :act_relations_as_parent, dependent: :destroy
  has_many :parents, through: :act_relations_as_child, dependent: :destroy

  has_many :act_localizations, foreign_key: :act_id
  has_many :localizations, through: :act_localizations, dependent: :destroy

  has_many :act_actor_relations, foreign_key: :act_id
  has_many :actors, through: :act_actor_relations, dependent: :destroy

  has_many :act_indicator_relations, foreign_key: :act_id
  has_many :indicators, through: :act_indicator_relations, dependent: :destroy

  has_many :comments, as: :commentable

  # Categories
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :organization_types,     -> { where(type: 'OrganizationType')    }, class_name: 'Category'
  has_and_belongs_to_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') }, class_name: 'Category'
  has_and_belongs_to_many :other_domains,          -> { where(type: 'OtherDomain')         }, class_name: 'Category'
  has_and_belongs_to_many :operational_fields,     -> { where(type: 'OperationalField')    }, class_name: 'Category'
  # For merged domains
  has_and_belongs_to_many :merged_domains,         -> { where(type: ['OtherDomain', 'SocioCulturalDomain']) }, class_name: 'Category', limit: 3

  accepts_nested_attributes_for :localizations,           allow_destroy: true
  accepts_nested_attributes_for :act_relations_as_child,  allow_destroy: true, reject_if: :parent_invalid
  accepts_nested_attributes_for :act_relations_as_parent, allow_destroy: true, reject_if: :child_invalid
  accepts_nested_attributes_for :act_actor_relations,     allow_destroy: true, reject_if: :actor_invalid
  accepts_nested_attributes_for :act_indicator_relations, allow_destroy: true, reject_if: :indicator_invalid
  accepts_nested_attributes_for :other_domains,                                reject_if: :other_domain_invalid

  after_create  :set_main_location,       if: 'localizations.any?'
  after_update  :set_main_location,       if: 'localizations.any?'
  before_update :deactivate_dependencies, if: '!active and active_changed?'

  scope :not_macros_parents, -> (child) { where(type: 'ActMacro').
                                          where('id NOT IN (SELECT parent_id FROM act_relations WHERE child_id=?)',
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActMeso').
                                          where('id NOT IN (SELECT parent_id FROM act_relations WHERE child_id=?)',
                                          child.id) }
  scope :meso_and_macro,     -> { where(type: ['ActMeso', 'ActMacro']) }

  scope :last_max_update,    -> { maximum(:updated_at)     }
  scope :recent,             -> { order('updated_at DESC') }

  validates :type,              presence: true
  validates :name,              presence: true
  validates :merged_domain_ids, presence: true

  validates_length_of :merged_domains, minimum: 1, maximum: 3

  def self.types
    %w(ActMacro ActMeso ActMicro)
  end

  def self.filter_acts(filters)
    actives   = filters[:active]['true']  if filters[:active].present?
    inactives = filters[:active]['false'] if filters[:active].present?

    acts = if actives.present?
             filter_actives
           elsif inactives.present?
             filter_inactives
           else
             all
           end
    acts
  end

  def membership_date(act, parent)
    relation   = act_relations_as_parent.get_dates(act, parent)
    start_date = relation.first.blank? ? 'now' : relation.first
    end_date   = relation.last.blank? ? 'now' : relation.last

    # Literal date format
    "from: #{start_date} - to: #{end_date}"
  end

  def macros_parents
    parents.where(type: 'ActMacro')
  end

  def mesos_parents
    parents.where(type: 'ActMeso')
  end

  def micros_parents
    parents.where(type: 'ActMicro')
  end

  def macros
    children.where(type: 'ActMacro')
  end

  def mesos
    children.where(type: 'ActMeso')
  end

  def micros
    children.where(type: 'ActMicro')
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

  def macro?
    type.include?('ActMacro')
  end

  def meso?
    type.include?('ActMeso')
  end

  def micro?
    type.include?('ActMicro')
  end

  def micro_or_meso?
    type.include?('ActMicro') || type.include?('ActMeso')
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

  def startdate
    start_date.to_date if start_date.present?
  end

  def enddate
    end_date.to_date if end_date.present?
  end

  def underscore
    to_s.underscore
  end

  def localizations_form
    collection = localizations
    collection.any? ? collection : localizations.build
  end

  def action_parents_form
    collection = act_relations_as_child
    collection.any? ? collection : act_relations_as_child.build
  end

  def action_children_form
    collection = act_relations_as_parent
    collection.any? ? collection : act_relations_as_parent.build
  end

  def actors_form
    collection = act_actor_relations
    collection.any? ? collection : act_actor_relations.build
  end

  def indicators_form
    collection = act_indicator_relations
    collection.any? ? collection : act_indicator_relations.build
  end

  def other_domains_form
    socio_cultural_domains.build
  end

  def main_locations
    act_localizations.main_locations
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

    def actor_invalid(attributes)
      attributes['actor_id'].empty? || attributes['relation_type_id'].empty?
    end

    def indicator_invalid(attributes)
      attributes['indicator_id'].empty? || attributes['relation_type_id'].empty?
    end

    def other_domain_invalid(attributes)
      attributes['name'].empty?
    end

    def set_main_location
      if act_localizations.main_locations.empty?
        act_localizations.order(:created_at).first.update( main: true )
      end
    end
end
