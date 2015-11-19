require 'rails_helper'

RSpec.describe ActRelation, type: :model do
  before :each do
    @user  = create(:user)
    @meso  = create(:act_meso, user_id: @user.id)
    @micro = create(:act_micro, user_id: @user.id)
  end

  let!(:meso_micro_params) do 
    { parent_id: @meso.id, child_id: @micro.id }
  end

  it 'Create Relation meso micro' do
    expect(@meso.name).to eq('Second one')
    expect(@micro.name).to eq('Third one')
    @relation = ActRelation.create!(meso_micro_params)
    expect(@micro.mesos_parents.first.name).to eq('Second one')
    expect(@meso.micros.first.name).to eq('Third one')
  end

  it 'Delete Relation macro meso' do
    @relation = ActRelation.create!(meso_micro_params)
    expect(@micro.mesos_parents.first.name).to eq('Second one')
    expect(@meso.micros.first.name).to eq('Third one')
    @meso.destroy
    expect(ActRelation.count).to eq(0)
  end

  it 'Find relation' do
    @relation = ActRelation.create!(meso_micro_params)
    @dates = ActRelation.get_dates(@micro, @meso)
    expect(@dates).to eq([nil, nil])
  end
end
