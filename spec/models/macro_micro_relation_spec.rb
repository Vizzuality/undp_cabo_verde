require 'rails_helper'

RSpec.describe MacroMicroRelation, type: :model do
  
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @micro  = create(:actor_micro, user_id: @user.id)
  end

  it "Create Relation macro - micro" do
    expect(@macro.name).to eq('Organization one')
    expect(@micro.name).to eq('Person one')
    @relation = MacroMicroRelation.create!(macro_id: @macro.id, micro_id: @micro.id)
    expect(@micro.macros.first.name).to eq('Organization one')
    expect(@macro.micros.first.name).to eq('Person one')
  end

  it "Delete Relation macro - meso" do
    @relation = MacroMicroRelation.create!(macro_id: @macro.id, micro_id: @micro.id)
    expect(@micro.macros.first.name).to eq('Organization one')
    expect(@macro.micros.first.name).to eq('Person one')
    @macro.destroy
    expect(MacroMesoRelation.count).to eq(0)
  end

end
