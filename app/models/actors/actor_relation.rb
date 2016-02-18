class ActorRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :parent, class_name: 'Actor', foreign_key: :parent_id, touch: true
  belongs_to :child,  class_name: 'Actor', foreign_key: :child_id, touch: true

  belongs_to :relation_type

  validate :end_date_after_start_date, if: 'start_date and end_date'

  def self.get_dates(actor, parent)
    @dates = where(child_id: actor.id, parent_id: parent.id).pluck(:start_date, :end_date)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end

  def find_parent_location
    Actor.find(self.parent_id).main_location
  end

  def find_child_location
    Actor.find(self.child_id).get_parent_main_location
  end

  private

    def end_date_after_start_date
      if end_date < start_date
        errors[:end_date] = 'End date must be after start date'
      end
    end
end