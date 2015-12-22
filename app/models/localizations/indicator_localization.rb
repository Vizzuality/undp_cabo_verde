class IndicatorLocalization < ActiveRecord::Base
  belongs_to :indicator, foreign_key: :indicator_id
  belongs_to :localization, foreign_key: :localization_id

  scope :main_locations, -> { where( main: true ) }
end
