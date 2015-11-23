require 'rails_helper'

describe RoutesHelper, type: :helper do
  include ApplicationHelper

  context 'For actors' do
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

    context 'Edit relation link' do
      it 'edit macro' do
        expect(helper.edit_relation(@micro, @meso)).to eq(actor_edit_actor_relation_path(@micro, @meso))
      end
    end

    context 'For comments' do
      it 'new comment path' do
        expect(helper.new_comment(@micro)).to eq(actor_comments_path(@micro))
      end

      it 'activate comment path' do
        expect(helper.activate_comment_path(@micro, @meso)).to eq(activate_actor_comment_path(@micro, @meso))
      end

      it 'deactivate comment path' do
        expect(helper.deactivate_comment_path(@micro, @meso)).to eq(deactivate_actor_comment_path(@micro, @meso))
      end
    end
  end

  context 'For acts' do
    before :each do
      @user  = create(:random_user)
      @macro = create(:act_macro, user_id: @user.id)
      @meso  = create(:act_meso, user_id: @user.id, parents: [@macro])
      @micro = create(:act_micro, user_id: @user.id, end_date: Time.zone.now, start_date: Time.zone.now - 30.years)
    end

    context 'Link and unlink macro' do
      it 'Link macro as meso' do
        expect(helper.link_act(@meso, @macro)).to eq(link_act_act_path(@meso, parent_id: @macro.id))
      end

      it 'Link macro as micro' do
        expect(helper.link_act(@micro, @macro)).to eq(link_act_act_path(@micro, parent_id: @macro.id))
      end

      it 'Unlink macro as meso' do
        expect(helper.unlink_act(@meso, @macro)).to eq(unlink_act_act_path(@meso, parent_id: @macro.id))
      end

      it 'Unlink macro as micro' do
        expect(helper.unlink_act(@micro, @macro)).to eq(unlink_act_act_path(@micro, parent_id: @macro.id))
      end
    end

    context 'link and unlink meso' do
      it 'Link meso as micro' do
        expect(helper.link_act(@micro, @meso)).to eq(link_act_act_path(@micro, parent_id: @meso.id))
      end

      it 'Unlink meso as micro' do
        expect(helper.unlink_act(@micro, @meso)).to eq(unlink_act_act_path(@micro, parent_id: @meso.id))
      end
    end

    context 'Edit relation link' do
      it 'edit macro' do
        expect(helper.edit_relation(@micro, @meso)).to eq(act_edit_act_relation_path(@micro, @meso))
      end
    end

    context 'For comments' do
      it 'new comment path' do
        expect(helper.new_comment(@micro)).to eq(act_comments_path(@micro))
      end

      it 'activate comment path' do
        expect(helper.activate_comment_path(@micro, @meso)).to eq(activate_act_comment_path(@micro, @meso))
      end

      it 'deactivate comment path' do
        expect(helper.deactivate_comment_path(@micro, @meso)).to eq(deactivate_act_comment_path(@micro, @meso))
      end
    end
  end
end
