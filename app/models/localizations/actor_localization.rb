class ActorLocalization < ActiveRecord::Base
  belongs_to :actor, foreign_key: :actor_id, touch: true
  belongs_to :localization, foreign_key: :localization_id, touch: true

  scope :main_locations, -> { where( main: true ) }
  scope :by_date,        -> (start_date, end_date) { filter_localizations(start_date, end_date) }

  after_update :check_main_location, if: 'main and main_changed?'

  def self.filter_localizations(start_date, end_date)
    @query = self

    if start_date && !end_date
      @query = @query.where("start_date >= ? OR end_date >= ?",
                             start_date.to_time.beginning_of_day, start_date.to_time.beginning_of_day)
    end

    if end_date && !start_date
      @query = @query.where("end_date <= ? OR start_date <= ?",
                             end_date.to_time.end_of_day, end_date.to_time.beginning_of_day)
    end

    if start_date && end_date
      @query = @query.where("start_date BETWEEN ? AND ? OR
                             end_date BETWEEN ? AND ? OR
                             ? BETWEEN start_date AND end_date",
                             start_date.to_time.beginning_of_day, end_date.to_time.end_of_day, start_date.to_time.beginning_of_day, end_date.to_time.end_of_day, start_date.to_time.beginning_of_day)
    end
    @query
  end
  
  private

    def check_main_location
      ActorLocalization.where.not(id: self.id).where( actor_id: self.actor_id ).each do |location|
        unless location.update(main: false)
          return false
        end
      end
    end
end
