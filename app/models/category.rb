class Category < ActiveRecord::Base
  extend ActsAsTree::TreeWalker
  acts_as_tree order: 'name'

  belongs_to :parent,   class_name: 'Category'
  has_many   :children, class_name: 'Category', foreign_key: :parent_id

  has_many :acts_categories
  has_many :acts, through: :acts_categories

  has_many :actors_categories
  has_many :actors, through: :actors_categories

  has_and_belongs_to_many :indicators

  validates :type, presence: true
  validates :name, presence: true
  validates :name, uniqueness: true

  scope :with_children,     -> { includes(:children) }
  scope :domain_categories, -> { where(type: ['SocioCulturalDomain', 'OtherDomain']).order(:name) }
  scope :scd_categories,    -> { where(type: 'SocioCulturalDomain').order(:name)                  }
  scope :od_categories,     -> { where(type: 'OtherDomain').order(:name)                          }
  scope :of_categories,     -> { where(type: 'OperationalField').order(:name)                     }
  scope :ot_categories,     -> { where(type: 'OrganizationType').order(:name)                     }

  def parent_name
    parent.try(:name)
  end

  def has_parent?
    parent.present?
  end

  def has_children?
    children.exists?
  end

  def self.types
    %w(OperationalField OrganizationType SocioCulturalDomain OtherDomain)
  end
end
