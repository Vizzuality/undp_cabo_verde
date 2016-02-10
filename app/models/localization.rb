class Localization < ActiveRecord::Base
  self.table_name = 'locations'

  include Activable

  belongs_to :user,        foreign_key: :user_id, touch: true
  belongs_to :localizable, polymorphic: true,     touch: true

  after_save   :fix_web
  after_update :check_main_location, if: 'main and main_changed?'

  validates :long, presence: true
  validates :lat,  presence: true

  scope :main_locations, -> { where( main: true ) }
  scope :by_date,        -> (start_date, end_date) { filter_localizations(start_date, end_date) }

  def self.filter_localizations(start_date, end_date)
    if start_date || end_date
      @first_date  = (Time.zone.now - 50.years).beginning_of_day
      @second_date = (Time.zone.now + 50.years).end_of_day
    end

    @query = self

    if start_date && !end_date
      @query = @query.where("COALESCE(start_date, '#{@first_date}') >= ? OR COALESCE(end_date, '#{@second_date}') >= ?",
                             start_date.to_time.beginning_of_day, start_date.to_time.beginning_of_day)
    end

    if end_date && !start_date
      @query = @query.where("COALESCE(end_date, '#{@second_date}') <= ? OR COALESCE(start_date, '#{@first_date}') <= ?",
                             end_date.to_time.end_of_day, end_date.to_time.beginning_of_day)
    end

    if start_date && end_date
      @query = @query.where("COALESCE(start_date, '#{@first_date}') BETWEEN ? AND ? OR
                             COALESCE(end_date, '#{@second_date}') BETWEEN ? AND ? OR
                             ? BETWEEN COALESCE(start_date, '#{@first_date}') AND COALESCE(end_date, '#{@second_date}')",
                             start_date.to_time.beginning_of_day, end_date.to_time.end_of_day, start_date.to_time.beginning_of_day, end_date.to_time.end_of_day, start_date.to_time.beginning_of_day)
    end

    @query = @query.distinct
  end

  private

    def fix_web
      unless self.web_url.blank? || self.web_url.start_with?('http://') || self.web_url.start_with?('https://')
        self.web_url = "http://#{self.web_url}"
      end
    end

    def check_main_location
      Localization.where.not(id: self.id).where( localizable_id: self.localizable_id, localizable_type: self.localizable_type ).each do |location|
        unless location.update(main: false)
          return false
        end
      end
    end
end
