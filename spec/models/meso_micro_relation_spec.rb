require 'rails_helper'

RSpec.describe ActorsMesoMicroRelation, type: :model do
  
  before :each do
    @user  = create(:user)
    @meso  = create(:actor_meso, user_id: @user.id)
    @micro = create(:actor_micro, user_id: @user.id)
  end

  let!(:meso_micro_params) do 
    { meso_id: @meso.id, micro_id: @micro.id }
  end

  it "Create Relation meso_micro" do
    expect(@meso.name).to eq('Department one')
    expect(@micro.name).to eq('Person one')
    @relation = ActorsMesoMicroRelation.create!(meso_micro_params)
    expect(@micro.mesos.first.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
  end

  it "Delete Relation macro_meso" do
    @relation = ActorsMesoMicroRelation.create!(meso_micro_params)
    expect(@micro.mesos.first.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
    @meso.destroy
    expect(ActorsMacroMesoRelation.count).to eq(0)
  end

end
