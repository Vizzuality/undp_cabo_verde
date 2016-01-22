require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  context 'For actors' do
    before :each do
      @user      = create(:random_user)
      @adminuser = create(:adminuser)
      FactoryGirl.create(:admin)

      @macro   = create(:actor_macro, user: @user)

      @comment   = create(:comment, user: @user, commentable: @macro)
      @comment_2 = create(:comment, user: @user, commentable: @macro, active: false)
    end

    let!(:attri) do
      { body: Faker::Lorem.paragraph(2, true, 4) }
    end

    let!(:attri_fail) do
      { body: '' }
    end

    context 'comments for actors' do
      before :each do
        sign_in @user
      end

      it 'User should be able to create a new comment for actor' do
        post :create, actor_id: @macro.id, comment: attri, user_id: @user.id
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(actor_path(@macro))
        expect(@macro.comments.size).to eq(3)
        expect(@macro.comments.first.body).not_to be_nil
        expect(@macro.comments.first.commentable_type).to eq('Actor')
      end

      context 'User should be able to activate, deactivate comments' do
        before :each do
          sign_in @user
          expect(@macro.comments.size).to eq(2)
        end

        it 'Activate comment' do
          patch :activate, id: @comment_2.id, actor_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(2)
        end

        it 'Deactivate comment' do
          patch :deactivate, id: @comment.id, actor_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(0)
          expect(@macro.comments.filter_inactives.size).to eq(2)
        end
      end

      context 'AdminUser should be able to activate, deactivate comments' do
        before :each do
          sign_in @adminuser
          expect(@macro.comments.size).to eq(2)
        end

        it 'Activate comment' do
          patch :activate, id: @comment_2.id, actor_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(2)
        end

        it 'Deactivate comment' do
          patch :deactivate, id: @comment.id, actor_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(0)
          expect(@macro.comments.filter_inactives.size).to eq(2)
        end
      end

      context 'Validation' do
        render_views

        it 'User should not be able to create comment without body' do
          post :create, actor_id: @macro.id, comment: attri_fail, user_id: @user.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
        end
      end
    end
  end

  context 'For acts' do
    before :each do
      @user      = create(:random_user)
      @adminuser = create(:adminuser)
      FactoryGirl.create(:admin)

      @macro   = create(:act_macro, user: @user)

      @comment   = create(:comment, user: @user, commentable: @macro)
      @comment_2 = create(:comment, user: @user, commentable: @macro, active: false)
    end

    let!(:attri) do
      { body: Faker::Lorem.paragraph(2, true, 4) }
    end

    let!(:attri_fail) do
      { body: '' }
    end

    context 'comments for acts' do
      before :each do
        sign_in @user
      end

      it 'User should be able to create a new comment for act' do
        post :create, act_id: @macro.id, comment: attri
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(act_path(@macro))
        expect(@macro.comments.size).to eq(3)
        expect(@macro.comments.first.body).not_to be_nil
        expect(@macro.comments.first.commentable_type).to eq('Act')
      end

      context 'User should be able to activate, deactivate comments' do
        before :each do
          sign_in @adminuser
          expect(@macro.comments.size).to eq(2)
        end

        it 'Activate comment' do
          patch :activate, id: @comment_2.id, act_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(2)
        end

        it 'Deactivate comment' do
          patch :deactivate, id: @comment.id, act_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(0)
          expect(@macro.comments.filter_inactives.size).to eq(2)
        end
      end

      context 'AdminUser should be able to activate, deactivate comments' do
        before :each do
          sign_in @adminuser
          expect(@macro.comments.size).to eq(2)
        end

        it 'Activate comment' do
          patch :activate, id: @comment_2.id, act_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(2)
        end

        it 'Deactivate comment' do
          patch :deactivate, id: @comment.id, act_id: @macro.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@macro.comments.filter_actives.size).to eq(0)
          expect(@macro.comments.filter_inactives.size).to eq(2)
        end
      end

      context 'Validation' do
        render_views

        it 'User should not be able to create comment without body' do
          post :create, act_id: @macro.id, comment: attri_fail, user_id: @user.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
        end
      end
    end
  end

  context 'For indicators' do
    before :each do
      @user      = create(:random_user)
      @adminuser = create(:adminuser)
      FactoryGirl.create(:admin)

      @indicator   = create(:indicator, user: @user)

      @comment   = create(:comment, user: @user, commentable: @indicator)
      @comment_2 = create(:comment, user: @user, commentable: @indicator, active: false)
    end

    let!(:attri) do
      { body: Faker::Lorem.paragraph(2, true, 4) }
    end

    let!(:attri_fail) do
      { body: '' }
    end

    context 'comments for indicators' do
      before :each do
        sign_in @user
      end

      it 'User should be able to create a new comment for indicator' do
        post :create, indicator_id: @indicator.id, comment: attri, user_id: @user.id
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(indicator_path(@indicator))
        expect(@indicator.comments.size).to eq(3)
        expect(@indicator.comments.first.body).not_to be_nil
        expect(@indicator.comments.first.commentable_type).to eq('Indicator')
      end

      context 'User should be able to activate, deactivate comments' do
        before :each do
          sign_in @user
          expect(@indicator.comments.size).to eq(2)
        end

        it 'Activate comment' do
          patch :activate, id: @comment_2.id, indicator_id: @indicator.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@indicator.comments.filter_actives.size).to eq(2)
        end

        it 'Deactivate comment' do
          patch :deactivate, id: @comment.id, indicator_id: @indicator.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@indicator.comments.filter_actives.size).to eq(0)
          expect(@indicator.comments.filter_inactives.size).to eq(2)
        end
      end

      context 'AdminUser should be able to activate, deactivate comments' do
        before :each do
          sign_in @adminuser
          expect(@indicator.comments.size).to eq(2)
        end

        it 'Activate comment' do
          patch :activate, id: @comment_2.id, indicator_id: @indicator.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@indicator.comments.filter_actives.size).to eq(2)
        end

        it 'Deactivate comment' do
          patch :deactivate, id: @comment.id, indicator_id: @indicator.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
          expect(@indicator.comments.filter_actives.size).to eq(0)
          expect(@indicator.comments.filter_inactives.size).to eq(2)
        end
      end

      context 'Validation' do
        render_views

        it 'User should not be able to create comment without body' do
          post :create, indicator_id: @indicator.id, comment: attri_fail, user_id: @user.id
          expect(response).to be_redirect
          expect(response).to have_http_status(302)
        end
      end
    end
  end
end
