require 'rails_helper'

RSpec.describe Unit, type: :model do
  before :each do
    @user                   = create(:user)
    @unit                   = create(:unit)
    @act_indicator_relation = create(:act_indicator_relation, act_id: 1, indicator_id: 1, unit: @unit, user: @user)
    @measurement            = create(:measurement, act_indicator_relation: @act_indicator_relation, unit: @unit, user: @user)
  end
  
  it 'Units count' do
    expect(Unit.count).to eq(1)
    expect(@unit.name).to eq('Euro')
    expect(@unit.symbol).to eq('€')
    expect(@unit.act_indicator_relations.count).to eq(1)
    expect(@unit.measurements.count).to eq(1)
  end
end
