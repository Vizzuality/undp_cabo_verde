class Indicator < ActiveRecord::Base
  include Activable
  include Localizable

  belongs_to :user, foreign_key: :user_id

  has_many :indicator_localizations, foreign_key: :indicator_id
  has_many :localizations, through: :indicator_localizations, dependent: :destroy

  has_many :act_indicator_relations, foreign_key: :indicator_id
  has_many :acts, through: :act_indicator_relations, dependent: :destroy

  has_many :comments, as: :commentable

  # Categories
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') }, class_name: 'Category'
  has_and_belongs_to_many :other_domains,          -> { where(type: 'OtherDomain')         }, class_name: 'Category'
  
  accepts_nested_attributes_for :localizations,           allow_destroy: true
  
  after_create  :set_main_location,       if: 'localizations.any?'
  after_update  :set_main_location,       if: 'localizations.any?'
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

  def main_locations
    indicator_localizations.main_locations
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

    def set_main_location
      if indicator_localizations.main_locations.empty?
        indicator_localizations.order(:created_at).first.update( main: true )
      end
    end
end
