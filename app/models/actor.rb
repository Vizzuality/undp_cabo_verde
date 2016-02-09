class Actor < ActiveRecord::Base
  include Activable
  include Localizable
  include Filterable

  belongs_to :user, foreign_key: :user_id
  belongs_to :location, class_name: 'Localization', foreign_key: :parent_location_id

  has_many :actor_relations_as_parent, class_name: 'ActorRelation', foreign_key: :parent_id
  has_many :actor_relations_as_child,  class_name: 'ActorRelation', foreign_key: :child_id

  has_many :children, through: :actor_relations_as_parent, dependent: :destroy
  has_many :parents,  through: :actor_relations_as_child,  dependent: :destroy

  has_many :act_actor_relations, foreign_key: :actor_id
  has_many :acts, through: :act_actor_relations, dependent: :destroy

  has_many :comments,      as: :commentable, dependent: :destroy
  has_many :localizations, as: :localizable, dependent: :destroy

  # Categories
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :organization_types,     -> { where(type: 'OrganizationType')    }, class_name: 'Category'
  has_and_belongs_to_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') }, class_name: 'Category', limit: 3
  has_and_belongs_to_many :other_domains,          -> { where(type: 'OtherDomain')         }, class_name: 'Category', limit: 3
  has_and_belongs_to_many :operational_fields,     -> { where(type: 'OperationalField')    }, class_name: 'Category', limit: 1
  # For merged domains
  has_and_belongs_to_many :merged_domains,         -> { where(type: ['OtherDomain', 'SocioCulturalDomain']) }, class_name: 'Category', limit: 3

  accepts_nested_attributes_for :localizations,             allow_destroy: true
  accepts_nested_attributes_for :actor_relations_as_child,  allow_destroy: true, reject_if: :parent_invalid
  accepts_nested_attributes_for :actor_relations_as_parent, allow_destroy: true, reject_if: :child_invalid
  accepts_nested_attributes_for :act_actor_relations,       allow_destroy: true, reject_if: :action_invalid
  accepts_nested_attributes_for :other_domains,                                  reject_if: :other_domain_invalid

  after_create  :set_main_location,       if: 'localizations.any?'
  after_update  :set_main_location,       if: 'localizations.any?'
  before_update :deactivate_dependencies, if: '!active and active_changed?'

  after_commit  :set_parent_location, on: [:create, :update], if: 'parents_locations and micro? and :persisted?'

  validates :type, presence: true
  validates :name, presence: true
  validates :socio_cultural_domain_ids, presence: true

  validates_length_of :socio_cultural_domains, minimum: 1, maximum: 3

  # Begin scopes
  scope :not_macros_parents, -> (child) { where(type: 'ActorMacro').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)',
                                          child.id) }
  scope :not_mesos_parents,  -> (child) { where(type: 'ActorMeso').
                                          where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)',
                                          child.id) }

  scope :last_max_update, -> { maximum(:updated_at)                     }
  scope :recent,          -> { order('updated_at DESC')                 }
  scope :meso_and_macro,  -> { where(type: ['ActorMeso', 'ActorMacro']) }
  scope :only_micro,      -> { where(type: 'ActorMicro')                }
  scope :with_locations,  -> { joins(:localizations)                    }
  # Used in serach
  scope :only_meso_and_macro_locations, -> { where(type: ['ActorMeso', 'ActorMacro']).joins(:localizations) }
  scope :only_micro_locations,          -> { where(type: 'ActorMicro').joins(:location)                     }

  # Actors selection
  scope :exclude_self_for_select,     -> (actor)  { where.not(id: actor.id).order(:name).filter_actives }
  scope :exclude_parents_for_select,  -> (actor)  { where('id NOT IN (SELECT parent_id FROM actor_relations WHERE child_id=?)', actor.id).
                                                    order(:name).filter_actives }
  scope :exclude_children_for_select, -> (actor)  { where('id NOT IN (SELECT child_id FROM actor_relations WHERE parent_id=?)', actor.id).
                                                    order(:name).filter_actives }
  # For actions
  scope :exclude_related_actors,      -> (action) { where('id NOT IN (SELECT actor_id FROM act_actor_relations WHERE act_id=?)', action.id).
                                                    order(:name).filter_actives }
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

  def get_parents_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date, levels: @levels, domains_ids: @domains,
           model_name: 'actor', relation_name: 'parents')
  end

  def get_children_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date, levels: @levels, domains_ids: @domains,
           model_name: 'actor', relation_name: 'children')
  end

  def get_actions_by_date(options)
    filter_params(options)
    filter(start_date: @start_date, end_date: @end_date, levels: @levels, domains_ids: @domains,
           model_name: 'act', relation_name: 'acts')
  end

  def get_locations
    locations = if micro? && localizations.blank?
                  # Get location from parent_location_id (main parent location) unless parent_location_id present get all parents main locations
                  parent_location_id.present? ? Localization.where(id: parent_location_id) : get_all_parents_locations
                else
                  localizations.filter_actives
                end
  end

  def get_all_parents_locations
    # Get main locations from all parents
    get_parents.present? ? get_parents.map { |p| p.main_location } : []
  end

  def get_locations_by_date(options)
    start_date = options['start_date'] if options['start_date'].present?
    end_date   = options['end_date']   if options['end_date'].present?

    get_locations.by_date(start_date, end_date)
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

  def locations?
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
    localizations.main_locations
  end

  def parents_locations
    get_parents.map { |p| ["#{p.name} (#{p.main_address})", p.main_location_id] } if get_parents.present?
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

    def includes_actor_relations_belongs(child)
      # relation_type_id: 2 for belongs to actor - actor relation
      ActorRelation.where(relation_type_id: 2, child_id: child.id).pluck(:parent_id)
    end

    def get_parents
      parent_ids = includes_actor_relations_belongs(self)
      locations  = if parent_ids.present?
                     Actor.filter_actives.where(id: parent_ids).with_locations.preload(:localizations)
                   end
    end

    def filter_params(options)
      @start_date = options['start_date']  if options['start_date'].present?
      @end_date   = options['end_date']    if options['end_date'].present?
      @levels     = options['levels']      if options['level'].present?
      @domains    = options['domains_ids'] if options['domains_ids'].present?
    end

    def set_main_location
      if localizations.main_locations.empty?
        localizations.order(:created_at).first.update( main: true )
      end
    end

    def set_parent_location
      if !parent_location_id && parents_locations.any?
        self.update!(parent_location_id: parents_locations.first[1])
      end
    end
end
