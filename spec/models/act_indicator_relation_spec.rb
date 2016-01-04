require 'rails_helper'

RSpec.describe ActIndicatorRelation, type: :model do
  before :each do
    @user          = create(:user)
    @unit          = create(:unit, user: @user)
    @indicator_1   = create(:indicator, user: @user)
    @indicator_2   = create(:indicator, name: 'Indicator two', user: @user)
    @act           = create(:act_meso, user_id: @user.id, indicators: [@indicator_1, @indicator_2])
    @relation_1    = ActIndicatorRelation.find_by(act_id: @act.id, indicator_id: @indicator_1.id)
    @relation_2    = ActIndicatorRelation.find_by(act_id: @act.id, indicator_id: @indicator_2.id)
    @measurement_1 = create(:measurement, act_indicator_relation: @relation_1, unit: @unit, user: @user, date: Time.zone.now)
    @measurement_2 = create(:measurement, act_indicator_relation: @relation_2, unit: @unit, user: @user, date: Time.zone.now)
  end

  it 'Create Relation act indicator' do
    expect(@relation_1.indicator.name).to eq('Indicator one')
    expect(@relation_1.act.name).to eq('Second one')
    expect(ActIndicatorRelation.count).to eq(2)
  end

  it 'Delete Relation act indicator' do
    @act.destroy
    expect(ActIndicatorRelation.count).to eq(0)
  end

  it 'Get relations dates' do
    @relation = @relation_1.update_attributes(start_date: Time.zone.now, end_date: 31.days.from_now, deadline: 30.days.from_now, unit: @unit)
    expect(ActIndicatorRelation.get_dates(@act, @indicator_1)).to eq(["September  1, 2015", "October  2, 2015", "October  1, 2015"])
  end

  it 'Get relations start_date' do
    @relation = @relation_2.update_attributes(start_date: Time.zone.now - 30.years, unit: @unit)
    expect(ActIndicatorRelation.get_dates(@act, @indicator_2)).to eq(["September  1, 1985", nil, nil])
  end

  it 'Get relations end_date' do
    @relation = @relation_2.update_attributes(end_date: Time.zone.now, unit: @unit)
    expect(ActIndicatorRelation.get_dates(@act, @indicator_2)).to eq([nil, "September  1, 2015", nil])
  end

  it 'Get relations deadline' do
    @relation = @relation_2.update_attributes(deadline: Time.zone.now, unit: @unit)
    expect(ActIndicatorRelation.get_dates(@act, @indicator_2)).to eq([nil, nil, "September  1, 2015"])
  end
end
