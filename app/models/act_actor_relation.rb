class ActActorRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :act,   foreign_key: :act_id, touch: true
  belongs_to :actor, foreign_key: :actor_id, touch: true

  belongs_to :relation_type

  def self.get_dates(act, actor)
    @dates = where(act_id: act.id, actor_id: actor.id).pluck(:start_date, :end_date)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end
end
