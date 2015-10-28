require 'rails_helper'

RSpec.describe MacroMesoRelation, type: :model do
  
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id)
  end

  it "Create Relation macro - meso" do
    expect(@macro.name).to eq('Organization one')
    expect(@meso.name).to eq('Department one')
    @relation = MacroMesoRelation.create!(macro_id: @macro.id, meso_id: @meso.id)
    expect(@meso.macros.first.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
  end

  it "Delete Relation macro - meso" do
    @relation = MacroMesoRelation.create!(macro_id: @macro.id, meso_id: @meso.id)
    expect(@meso.macros.first.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
    @meso.destroy
    expect(MacroMesoRelation.count).to eq(0)
  end

end
