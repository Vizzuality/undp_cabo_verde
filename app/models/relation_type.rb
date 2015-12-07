class RelationType < ActiveRecord::Base
  has_many :act_actor_relations
  has_many :act_relations
  has_many :actor_relations

  RELATIONS_CATEGORY_NAMES = %w(actor\ -\ actor\ (link) actor\ -\ actor\ (embeded) actor\ -\ action actor\ -\ artifact action\ -\ indicator action\ -\ artifact action\ -\ action)

  validates :title,         presence: true
  validates :title_reverse, presence: true

  scope :includes_actor_relations, -> { where(relation_category: [1, 2]) }
  scope :includes_act_relations,   -> { where(relation_category: [7])    }

  def relation_categories
    RELATIONS_CATEGORY_NAMES[relation_category - 1]
  end

  def self.relation_categories
    RELATIONS_CATEGORY_NAMES
  end
end
