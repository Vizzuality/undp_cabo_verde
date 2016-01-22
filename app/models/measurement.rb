class Measurement < ActiveRecord::Base
  include Activable

  belongs_to :user, foreign_key: :user_id
  belongs_to :unit, foreign_key: :unit_id

  belongs_to :act_indicator_relation, foreign_key: :act_indicator_relation_id, touch: true

  validates :value,   presence: true
  validates :unit_id, presence: true
  validates :date,    presence: true

  def unit_symbol
    unit.symbol
  end

  def unit_name
    unit.name
  end

  def formated_date
    date.to_date.to_formatted_s(:long).to_s if date.present?
  end
end
