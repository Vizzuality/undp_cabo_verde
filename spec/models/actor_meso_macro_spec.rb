require 'rails_helper'

RSpec.describe ActorMesoMacro, type: :model do
  
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id)
  end

  let!(:macro_meso_params) do
    { macro_id: @macro.id, meso_id: @meso.id }
  end

  it "Create Relation macro meso" do
    expect(@macro.name).to eq('Organization one')
    expect(@meso.name).to eq('Department one')
    @relation = ActorMesoMacro.create!(macro_meso_params)
    expect(@meso.macros.first.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
  end

  it "Delete Relation macro meso" do
    @relation = ActorMesoMacro.create!(macro_meso_params)
    expect(@meso.macros.first.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
    @meso.destroy
    expect(ActorMesoMacro.count).to eq(0)
  end

end
