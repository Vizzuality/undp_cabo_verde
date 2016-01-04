class Comment < ActiveRecord::Base
  include Activable

  belongs_to :user, foreign_key: :user_id
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true
end
