require 'rails_helper'

describe ActorsHelper, type: :helper do
  include ApplicationHelper

  before :each do
    @user  = create(:random_user)
    @micro = create(:actor_micro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id)
  end

  context 'Link and unlink macro' do
    it 'Link macro as meso' do
      @id = 1
      expect(helper.sti_link_macro(@meso, @id)).to eq(link_macro_actor_meso_path(@meso, macro_id: 1))
    end

    it 'Link macro as micro' do
      @id = 1
      expect(helper.sti_link_macro(@micro, @id)).to eq(link_macro_actor_micro_path(@micro, macro_id: 1))
    end

    it 'Unlink macro as meso' do
      @id = 1
      expect(helper.sti_unlink_macro(@meso, @id)).to eq(unlink_macro_actor_meso_path(@meso, relation_id: 1))
    end

    it 'Unlink macro as micro' do
      @id = 1
      expect(helper.sti_unlink_macro(@micro, @id)).to eq(unlink_macro_actor_micro_path(@micro, relation_id: 1))
    end
  end

  context 'link and unlink meso' do
    it "Link meso as micro" do
      @id = 1
      expect(helper.sti_link_meso(@micro, @id)).to eq(link_meso_actor_micro_path(@micro, meso_id: 1))
    end

    it "Unlink meso as micro" do
      @id = 1
      expect(helper.sti_unlink_meso(@micro, @id)).to eq(unlink_meso_actor_micro_path(@micro, relation_id: 1))
    end
  end
end
