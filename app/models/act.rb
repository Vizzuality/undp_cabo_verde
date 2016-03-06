class Act < ActiveRecord::Base
  include Activable
  include Localizable
  include Filterable
  include Commentable

  monetize :budget_cents, allow_nil: true

  belongs_to :user, foreign_key: :user_id

  has_many :act_relations_as_parent, class_name: 'ActRelation', foreign_key: :parent_id
  has_many :act_relations_as_child,  class_name: 'ActRelation', foreign_key: :child_id

  has_many :children, through: :act_relations_as_parent, dependent: :destroy
  has_many :parents, through: :act_relations_as_child, dependent: :destroy

  has_many :act_actor_relations, foreign_key: :act_id
  has_many :actors, through: :act_actor_relations, dependent: :destroy

  has_many :act_indicator_relations, foreign_key: :act_id
  has_many :indicators, through: :act_indicator_relations, dependent: :destroy

  # Categories
  has_many :acts_categories
  has_many :categories, through: :acts_categories
  has_many :organization_types, -> { where(type: 'OrganizationType') },
    through: :acts_categories, source: :category
  has_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') },
    through: :acts_categories, source: :category
  has_many :other_domains, -> { where(type: 'OtherDomain') },
    through: :acts_categories, source: :category
  has_many :operational_fields, -> { where(type: 'OperationalField') },
    through: :acts_categories, source: :category

  # For merged domains
  has_many :merged_domains, -> { where(type: ['OtherDomain', 'SocioCulturalDomain']) },
    through: :acts_categories, source: :category

  accepts_nested_attributes_for :act_relations_as_child,  allow_destroy: true, reject_if: :parent_invalid
  accepts_nested_attributes_for :act_relations_as_parent, allow_destroy: true, reject_if: :child_invalid
  accepts_nested_attributes_for :act_actor_relations,     allow_destroy: true, reject_if: :actor_invalid
  accepts_nested_attributes_for :act_indicator_relations, allow_destroy: true, reject_if: :indicator_invalid
  accepts_nested_attributes_for :other_domains,                                reject_if: :other_domain_invalid

  before_update :deactivate_dependencies, if: '!active and active_changed?'

  validates :type, presence: true
  validates :name, presence: true
  validates :socio_cultural_domain_ids, presence: true, unless: -> (act) { act.other_domain_ids.present?          }
  validates :other_domain_ids,          presence: true, unless: -> (act) { act.socio_cultural_domain_ids.present? }

  validates_length_of :socio_cultural_domains, minimum: 0, maximum: 3
  validates_length_of :other_domains,          minimum: 0, maximum: 3

  validates_with EndDateValidator

  # Begin scopes
  scope :not_macros_parents, -> (child) { where(type: 'ActMacro').
                                          where('id NOT IN (SELECT parent_id FROM act_relations WHERE child_id=?)',
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActMeso').
                                          where('id NOT IN (SELECT parent_id FROM act_relations WHERE child_id=?)',
                                          child.id) }
  scope :meso_and_macro,     -> { where(type: ['ActMeso', 'ActMacro']) }

  scope :last_max_update,    -> { maximum(:updated_at)     }
  scope :recent,             -> { order('updated_at DESC') }

  # Actions selection
  scope :exclude_self_for_select,     -> (action) { where.not(id: action.id).order(:name).filter_actives }
  scope :exclude_parents_for_select,  -> (action) { where('id NOT IN (SELECT parent_id FROM act_relations WHERE child_id=?)', action.id).
                                                   order(:name).filter_actives }
  scope :exclude_children_for_select, -> (action) { where('id NOT IN (SELECT child_id FROM act_relations WHERE parent_id=?)', action.id).
                                                   order(:name).filter_actives }
  # For actors
  scope :exclude_related_actions,     -> (actor)  { where('id NOT IN (SELECT act_id FROM act_actor_relations WHERE actor_id=?)', actor.id).
                                                    order(:name).filter_actives }
  # For indicators
  scope :exclude_related_actions_for_indicator, -> (indicator) { where('id NOT IN (SELECT act_id FROM act_indicator_relations WHERE indicator_id=?)', indicator.id).
                                                                 order(:name).filter_actives }
  # End scopes

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

  def get_parents_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date, levels: @levels, domains_ids: @domains,
           model_name: 'act', relation_name: 'parents')
  end

  def get_children_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date, levels: @levels, domains_ids: @domains,
           model_name: 'act', relation_name: 'children')
  end

  def get_actors_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date, levels: @levels, domains_ids: @domains,
           model_name: 'actor', relation_name: 'actors')
  end

  def get_values_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date,
           model_name: 'act_indicator_relation')
  end

  def get_locations
    localizations.filter_actives
  end

  def get_locations_by_date(options)
    # Don't filter locations by date for Actions
    # start_date = options['start_date'] if options['start_date'].present?
    # end_date   = options['end_date']   if options['end_date'].present?

    # get_locations.by_date(start_date, end_date)
    get_locations
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

  def is_actor?
    self.class.name.include?('Actor')
  end

  private

    def deactivate_dependencies
      localizations.filter_actives.each do |location|
        unless location.deactivate
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
      attributes['parent_id'].blank? || attributes['relation_type_id'].blank?
    end

    def child_invalid(attributes)
      attributes['child_id'].blank? || attributes['relation_type_id'].blank?
    end

    def actor_invalid(attributes)
      attributes['actor_id'].blank? || attributes['relation_type_id'].blank?
    end

    def indicator_invalid(attributes)
      attributes['indicator_id'].blank? || attributes['relation_type_id'].blank?
    end

    def other_domain_invalid(attributes)
      attributes['name'].blank?
    end

    def filter_params(options)
      @start_date = options['start_date']  if options['start_date'].present?
      @end_date   = options['end_date']    if options['end_date'].present?
      @levels     = options['levels']      if options['level'].present?
      @domains    = options['domains_ids'] if options['domains_ids'].present?
    end
end
