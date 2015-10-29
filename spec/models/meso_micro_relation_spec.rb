require 'rails_helper'

RSpec.describe MesoMicroRelation, type: :model do
  
  before :each do
    @user  = create(:user)
    @meso = create(:actor_meso, user_id: @user.id)
    @micro  = create(:actor_micro, user_id: @user.id)
  end

  it "Create Relation meso - micro" do
    expect(@meso.name).to eq('Department one')
    expect(@micro.name).to eq('Person one')
    @relation = MesoMicroRelation.create!(meso_id: @meso.id, micro_id: @micro.id)
    expect(@micro.mesos.first.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
  end

  it "Delete Relation macro - meso" do
    @relation = MesoMicroRelation.create!(meso_id: @meso.id, micro_id: @micro.id)
    expect(@micro.mesos.first.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
    @meso.destroy
    expect(MacroMesoRelation.count).to eq(0)
  end

end