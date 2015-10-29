require 'rails_helper'

RSpec.describe ActorsMacroMesoRelation, type: :model do
  
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id)
  end

  let!(:macro_meso_params) do
    { macro_id: @macro.id, meso_id: @meso.id }
  end

  it "Create Relation macro_meso" do
    expect(@macro.name).to eq('Organization one')
    expect(@meso.name).to eq('Department one')
    @relation = ActorsMacroMesoRelation.create!(macro_meso_params)
    expect(@meso.macros.first.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
  end

  it "Delete Relation macro_meso" do
    @relation = ActorsMacroMesoRelation.create!(macro_meso_params)
    expect(@meso.macros.first.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
    @meso.destroy
    expect(ActorsMacroMesoRelation.count).to eq(0)
  end

end
