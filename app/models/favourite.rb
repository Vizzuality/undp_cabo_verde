class Favourite < ActiveRecord::Base
  include Sanitizable

  belongs_to :user, foreign_key: :user_id

  after_create :set_position, unless: 'position_changed?'

  validates :uri, presence: true

  scope :positioned,       -> { order(position: :asc)    }
  scope :recent,           -> { order(updated_at: :desc) }
  scope :last_max_updated, -> { maximum(:updated_at)     }

  private

    def set_position
      self.update_attributes(position: Favourite.where(user_id: self.user_id).maximum(:position) + 1)
    end
end
