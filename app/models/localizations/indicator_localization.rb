class IndicatorLocalization < ActiveRecord::Base
  belongs_to :indicator, foreign_key: :indicator_id
  belongs_to :localization, foreign_key: :localization_id

  scope :main_locations, -> { where( main: true ) }

  after_update :check_main_location, if: 'main and main_changed?'
  
  private

    def check_main_location
      IndicatorLocalization.where.not(id: self.id).where( indicator_id: self.indicator_id ).each do |location|
        unless location.update(main: false)
          return false
        end
      end
    end
end
