class ActionLocalization < ActiveRecord::Base
  belongs_to :action, foreign_key: :action_id
  belongs_to :localization, foreign_key: :localization_id
end
