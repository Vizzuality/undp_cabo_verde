class ActLocalization < ActiveRecord::Base
  belongs_to :act, foreign_key: :act_id, touch: true
  belongs_to :localization, foreign_key: :localization_id, touch: true

  scope :main_locations, -> { where( main: true ) }

  after_update :check_main_location, if: 'main and main_changed?'

  private

    def check_main_location
      ActLocalization.where.not(id: self.id).where( act_id: self.act_id ).each do |location|
        unless location.update(main: false)
          return false
        end
      end
    end
end
