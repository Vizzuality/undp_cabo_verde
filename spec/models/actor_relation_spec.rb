require 'rails_helper'

RSpec.describe ActorRelation, type: :model do
  before :each do
    @user  = create(:user)
    @meso  = create(:actor_meso, user_id: @user.id)
    @micro = create(:actor_micro, user_id: @user.id)
  end

  let!(:meso_micro_params) do 
    { parent_id: @meso.id, child_id: @micro.id }
  end

  it 'Create Relation meso micro' do
    expect(@meso.name).to eq('Department one')
    expect(@micro.name).to eq('Person one')
    @relation = ActorRelation.create!(meso_micro_params)
    expect(@micro.mesos_parents.first.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
  end

  it 'Delete Relation macro meso' do
    @relation = ActorRelation.create!(meso_micro_params)
    expect(@micro.mesos_parents.first.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
    @meso.destroy
    expect(ActorRelation.count).to eq(0)
  end

  it 'Find relation dates' do
    @relation = ActorRelation.create!(meso_micro_params)
    @dates = ActorRelation.get_dates(@micro, @meso)
    expect(@dates).to eq([nil, nil])
  end
end
