class ActRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :parent, class_name: 'Act', foreign_key: :parent_id, touch: true
  belongs_to :child,  class_name: 'Act', foreign_key: :child_id, touch: true

  belongs_to :relation_type

  def self.get_dates(act, parent)
    @dates = where(child_id: act.id, parent_id: parent.id).pluck(:start_date, :end_date)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end

  def find_parent_location
  	Act.find(self.parent_id).main_location
  end

  def find_child_location
  	Act.find(self.child_id).main_location
  end
end
