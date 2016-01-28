class Localization < ActiveRecord::Base
  self.table_name = 'locations'

  include Activable

  belongs_to :user,       foreign_key: :user_id, touch: true
  belongs_to :localizable, polymorphic: true,     touch: true

  after_save   :fix_web
  after_update :check_main_location, if: 'main and main_changed?'

  validates :long, presence: true
  validates :lat,  presence: true

  scope :main_locations, -> { where( main: true ) }
  scope :by_date,        -> (start_date, end_date) { filter_localizations(start_date, end_date) }

  def actor_macros
    actors.where(type: 'ActorMacro')
  end

  def actor_mesos
    actors.where(type: 'ActorMeso')
  end

  def actor_micros
    actors.where(type: 'ActorMicro')
  end

  def act_macros
    acts.where(type: 'ActMacro')
  end

  def act_mesos
    acts.where(type: 'ActMeso')
  end

  def act_micros
    acts.where(type: 'ActMicro')
  end

  def self.filter_localizations(start_date, end_date)
    @query = self

    if start_date && !end_date
      @query = @query.where("COALESCE(start_date, '#{Time.zone.now.change(year: 1900)}') >= ? OR COALESCE(end_date, '#{Time.zone.now.change(year: 2100)}') >= ?",
                             start_date.to_time.beginning_of_day, start_date.to_time.beginning_of_day)
    end

    if end_date && !start_date
      @query = @query.where("COALESCE(end_date, '#{Time.zone.now.change(year: 2100)}') <= ? OR COALESCE(start_date, '#{Time.zone.now.change(year: 1900)}') <= ?",
                             end_date.to_time.end_of_day, end_date.to_time.beginning_of_day)
    end

    if start_date && end_date
      @query = @query.where("COALESCE(start_date, '#{Time.zone.now.change(year: 1900)}') BETWEEN ? AND ? OR
                             COALESCE(end_date, '#{Time.zone.now.change(year: 2100)}') BETWEEN ? AND ? OR
                             ? BETWEEN COALESCE(start_date, '#{Time.zone.now.change(year: 1900)}') AND COALESCE(end_date, '#{Time.zone.now.change(year: 2100)}')",
                             start_date.to_time.beginning_of_day, end_date.to_time.end_of_day, start_date.to_time.beginning_of_day, end_date.to_time.end_of_day, start_date.to_time.beginning_of_day)
    end
    @query
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
