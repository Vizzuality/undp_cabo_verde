class ActLocalization < ActiveRecord::Base
  belongs_to :act, foreign_key: :act_id
  belongs_to :localization, foreign_key: :localization_id
end
