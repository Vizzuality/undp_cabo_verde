class Unit < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id
  
  has_many :act_indicator_relations
  has_many :measurements

  validates :name,   presence:   true
  validates :name,   uniqueness: true
  validates :symbol, presence:   true
  validates :symbol, uniqueness: true

  def not_associated
    act_indicator_relations.empty? && measurements.empty?
  end
end
