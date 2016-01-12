class Category < ActiveRecord::Base
  extend ActsAsTree::TreeWalker
  acts_as_tree order: 'name'

  belongs_to :parent,   class_name: 'Category'
  has_many   :children, class_name: 'Category', foreign_key: :parent_id

  has_and_belongs_to_many :actors
  has_and_belongs_to_many :acts
  has_and_belongs_to_many :indicators

  validates :type, presence: true
  validates :name, presence: true

  scope :with_children,     -> { includes(:children) }
  scope :domain_categories, -> { where(type: ['SocioCulturalDomain', 'OtherDomain']) }

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
