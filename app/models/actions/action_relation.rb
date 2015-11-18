class ActionRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :parent, class_name: 'Action', foreign_key: :parent_id
  belongs_to :child, class_name: 'Action', foreign_key: :child_id

  def self.get_dates(action, parent)
    @dates = where(child_id: action.id, parent_id: parent.id).pluck(:start_date, :end_date)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end
end
