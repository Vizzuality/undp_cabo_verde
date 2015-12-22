class ActorLocalization < ActiveRecord::Base
  belongs_to :actor, foreign_key: :actor_id
  belongs_to :localization, foreign_key: :localization_id

  scope :main_locations, -> { where( main: true ) }

  default_scope { order('main DESC') }
end
