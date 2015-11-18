class ActionActorRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :action, foreign_key: :action_id
  belongs_to :actor, foreign_key: :actor_id

  def self.get_dates(action, actor)
    @dates = where(action_id: action.id, actor_id: actor.id).pluck(:start_date, :end_date)
    @dates.flatten.map { |d| d.to_date.to_formatted_s(:long).to_s rescue nil } if @dates.present?
  end
end
