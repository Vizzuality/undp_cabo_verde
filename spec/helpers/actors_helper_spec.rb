require 'rails_helper'

describe ActorsHelper, type: :helper do
  include ApplicationHelper

  before :each do
    @user  = create(:random_user)
    @micro = create(:actor_micro, user_id: @user.id)
    @meso  = create(:actor_meso,  user_id: @user.id)
    @macro = create(:actor_macro, user_id: @user.id)
  end

  context 'Link and unlink macro' do
    it 'Link macro as meso' do
      expect(helper.link_actor(@meso, @macro)).to eq(link_actor_actor_path(@meso, parent_id: @macro.id))
    end

    it 'Link macro as micro' do
      expect(helper.link_actor(@micro, @macro)).to eq(link_actor_actor_path(@micro, parent_id: @macro.id))
    end

    it 'Unlink macro as meso' do
      expect(helper.unlink_actor(@meso, @macro)).to eq(unlink_actor_actor_path(@meso, parent_id: @macro.id))
    end

    it 'Unlink macro as micro' do
      expect(helper.unlink_actor(@micro, @macro)).to eq(unlink_actor_actor_path(@micro, parent_id: @macro.id))
    end
  end

  context 'link and unlink meso' do
    it 'Link meso as micro' do
      expect(helper.link_actor(@micro, @meso)).to eq(link_actor_actor_path(@micro, parent_id: @meso.id))
    end

    it 'Unlink meso as micro' do
      expect(helper.unlink_actor(@micro, @meso)).to eq(unlink_actor_actor_path(@micro, parent_id: @meso.id))
    end
  end
end
