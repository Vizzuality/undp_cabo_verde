class ActIndicatorRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :act,       foreign_key: :act_id, touch: true
  belongs_to :indicator, foreign_key: :indicator_id, touch: true
  belongs_to :unit,      foreign_key: :unit_id
  belongs_to :relation_type

  has_many :measurements, dependent: :destroy

  validate :end_date_after_start_date, if: 'start_date and end_date'

  accepts_nested_attributes_for :measurements, allow_destroy: true

  def self.get_dates(act, indicator)
    @dates = where(act_id: act.id, indicator_id: indicator.id).pluck(:start_date, :end_date, :deadline)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end

  def target_unit_symbol
    unit.symbol
  end

  def target_unit_name
    unit.name
  end

  private

    def end_date_after_start_date
      if end_date < start_date
        errors[:end_date] = 'End date must be after start date'
      end
    end
end
