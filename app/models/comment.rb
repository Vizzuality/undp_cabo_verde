class Comment < ActiveRecord::Base
  include Activable

  belongs_to :user, foreign_key: :user_id
  belongs_to :commentable, polymorphic: true, touch: true

  validates :body, presence: true

  scope :last_max_created, -> { maximum(:created_at)     }
  scope :recent,           -> { order('created_at DESC') }
end
