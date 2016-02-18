class ActActorRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :act,   foreign_key: :act_id, touch: true
  belongs_to :actor, foreign_key: :actor_id, touch: true

  belongs_to :relation_type

  validate :end_date_after_start_date, if: 'start_date and end_date'

  def self.get_dates(act, actor)
    @dates = where(act_id: act.id, actor_id: actor.id).pluck(:start_date, :end_date)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end

  def parent_id
    actor_id
  end

  def child_id
  	act_id
  end

  def find_parent_location
    Actor.find(self.parent_id).get_parent_main_location
  end

  def find_child_location
    Act.find(self.child_id).main_location
  end

  private

    def end_date_after_start_date
      if end_date < start_date
        errors[:end_date] = 'End date must be after start date'
      end
    end
end
