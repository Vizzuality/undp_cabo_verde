class Comment < ActiveRecord::Base
  include Activable

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true
end
