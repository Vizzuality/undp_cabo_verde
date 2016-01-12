class ActorLocalization < ActiveRecord::Base
  belongs_to :actor, foreign_key: :actor_id, touch: true
  belongs_to :localization, foreign_key: :localization_id, touch: true

  scope :main_locations, -> { where( main: true ) }

  after_update :check_main_location, if: 'main and main_changed?'
  
  private

    def check_main_location
      ActorLocalization.where.not(id: self.id).where( actor_id: self.actor_id ).each do |location|
        unless location.update(main: false)
          return false
        end
      end
    end
end
