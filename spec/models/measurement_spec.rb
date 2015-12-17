require 'rails_helper'

RSpec.describe Measurement, type: :model do
  before :each do
    @user                   = create(:user)
    @unit                   = create(:unit)
    @indicator              = create(:indicator, user_id: @user.id)
    @act                    = create(:act_meso, user_id: @user.id, indicators: [@indicator])
    @act_indicator_relation = create(:act_indicator_relation, act_id: @act, indicator_id: @indicator, unit: @unit, user: @user, start_date: Time.zone.now, end_date: 31.days.from_now, deadline: 30.days.from_now)
    @measurement_1          = create(:measurement, act_indicator_relation: @act_indicator_relation, unit: @unit, user: @user, date: Time.zone.now)
    @measurement_2          = create(:measurement, act_indicator_relation: @act_indicator_relation, unit: @unit, user: @user, date: Time.zone.now)
  end
  
  it 'Create measurements and get data' do
    expect(Measurement.count).to eq(2)
    expect(@unit.measurements.count).to eq(2)
    expect(@measurement_1.value).to eq(100.001)
    expect(@measurement_1.date).not_to be_nil
    expect(@measurement_1.details).not_to be_nil
    expect(@measurement_1.unit_name).to eq('Euro')
    expect(@measurement_2.unit_symbol).to eq('€')
  end

  it 'Create measurements and get data for action relation' do
    expect(@measurement_1.act_indicator_relation.target_unit_symbol).to eq('€')
    expect(@measurement_2.act_indicator_relation.target_unit_name).to eq('Euro')
    expect(@measurement_2.act_indicator_relation.target_value).to eq(100.001)
    expect(@measurement_2.formated_date).to eq('September  1, 2015')
  end
end
