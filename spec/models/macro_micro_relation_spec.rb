require 'rails_helper'

RSpec.describe ActorsMacroMicroRelation, type: :model do
  
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @micro = create(:actor_micro, user_id: @user.id)
  end

  let!(:macro_micro_params) do
    { macro_id: @macro.id, micro_id: @micro.id }
  end

  it "Create Relation macro_micro" do
    expect(@macro.name).to eq('Organization one')
    expect(@micro.name).to eq('Person one')
    @relation = ActorsMacroMicroRelation.create!(macro_micro_params)
    expect(@micro.macros.first.name).to eq('Organization one')
    expect(@macro.micros.first.name).to eq('Person one')
  end

  it "Delete Relation macro_meso" do
    @relation = ActorsMacroMicroRelation.create!(macro_micro_params)
    expect(@micro.macros.first.name).to eq('Organization one')
    expect(@macro.micros.first.name).to eq('Person one')
    @macro.destroy
    expect(ActorsMacroMesoRelation.count).to eq(0)
  end

end
