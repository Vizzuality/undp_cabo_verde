class Indicator < ActiveRecord::Base
  include Activable
  include Commentable
  include Taggable

  belongs_to :user, foreign_key: :user_id

  has_many :act_indicator_relations, foreign_key: :indicator_id
  has_many :acts, through: :act_indicator_relations, dependent: :destroy

  # Categories
  has_many :categories_indicators
  has_many :categories, through: :categories_indicators
  has_many :socio_cultural_domains, -> { where(type: 'SocioCulturalDomain') },
    through: :categories_indicators, source: :category
  has_many :other_domains, -> { where(type: 'OtherDomain') },
    through: :categories_indicators, source: :category

  accepts_nested_attributes_for :act_indicator_relations, allow_destroy: true,
    reject_if: :act_invalid

  before_update :deactivate_dependencies, if: '!active and active_changed?'

  validates :name,    presence: true
  validates :user_id, presence: true

  scope :last_max_update,    -> { maximum(:updated_at)     }
  scope :recent,             -> { order('updated_at DESC') }

  scope :exclude_related_indicators, -> (action) { where('id NOT IN (SELECT indicator_id FROM act_indicator_relations WHERE act_id=?)', action.id).
                                                   order(:name).filter_actives }

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

  def acts_size
    acts.size
  end

  def categories?
    categories.any?
  end

  def actions?
    acts.any?
  end

  private

    def deactivate_dependencies
      comments.filter_actives.each do |comment|
        unless comment.deactivate
          return false
        end
      end
    end

    def act_invalid(attributes)
      attributes['act_id'].blank? || attributes['relation_type_id'].blank?
    end

end

