class Tag < ActsAsTaggableOn::Tag
  has_many :taggings
  has_many :tags, through: :taggings

  scope :most_used_50, -> { most_used(50) }
end
