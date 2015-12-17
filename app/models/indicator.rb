class Indicator < ActiveRecord::Base
  include Activable

  belongs_to :user

  has_many :indicator_localizations, foreign_key: :indicator_id
  has_many :localizations, through: :indicator_localizations, dependent: :destroy

  has_many :act_indicator_relations, foreign_key: :indicator_id
  has_many :acts, through: :act_indicator_relations, dependent: :destroy

  has_many :comments, as: :commentable

  # Categories
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :organization_types,     -> { where(type: 'OrganizationType')    }, class_name: 'Category'
  has_and_belongs_to_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') }, class_name: 'Category'
  has_and_belongs_to_many :other_domains,          -> { where(type: 'OtherDomain')         }, class_name: 'Category'
  has_and_belongs_to_many :operational_fields,     -> { where(type: 'OperationalField')    }, class_name: 'Category'
  
  accepts_nested_attributes_for :localizations,           allow_destroy: true
  accepts_nested_attributes_for :act_indicator_relations, allow_destroy: true, reject_if: :act_invalid
  
  before_update :deactivate_dependencies, if: '!active and active_changed?'

  validates :name,    presence: true
  validates :user_id, presence: true

  def self.filter_indicators(filters)
    actives   = filters[:active]['true']  if filters[:active].present?
    inactives = filters[:active]['false'] if filters[:active].present?

    indicators = if actives.present?
                   filter_actives
                 elsif inactives.present?
                   filter_inactives
                 else
                   all
                 end
    indicators
  end

  def localizations?
    localizations.any?
  end

  def categories?
    categories.any?
  end

  def actions?
    acts.any?
  end

  def comments?
    comments.any?
  end

  private

    def deactivate_dependencies
      localizations.filter_actives.each do |localization|
        unless localization.deactivate
          return false
        end
      end

      comments.filter_actives.each do |comment|
        unless comment.deactivate
          return false
        end
      end
    end

    def act_invalid(attributes)
      attributes['act_id'].empty?
    end
end

