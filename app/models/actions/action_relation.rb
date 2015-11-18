class ActionRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :parent, class_name: 'Action', foreign_key: :parent_id
  belongs_to :child, class_name: 'Action', foreign_key: :child_id

  def self.get_dates(action, parent)
    find_by(child_id: action.id, parent_id: parent.id)
  end
end
