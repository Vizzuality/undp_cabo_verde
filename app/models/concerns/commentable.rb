module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy

    def comments?
      comments.any?
    end
  end

  class_methods do
  end
end

