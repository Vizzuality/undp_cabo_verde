require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @micro = create(:actor_micro, user_id: @user.id)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso,  user_id: @user.id)
    # First Category already created with actor_macro
    @category  = create(:category)
    @child_cat = create(:category, name: 'Category second', parent: @category, actors: [@micro, @meso])
  end

  let!(:attri) do
    { name: 'New cat name' }
  end

  let!(:attri_fail) do
    { name: '' }
  end

  let!(:attri_with_actor) do
    { name: 'New cat name', actor_ids: [@macro], type: 'SocioCulturalDomain' }
  end

  context 'User should be able to view categories' do
    before :each do
      sign_in @user
    end

    it 'GET index returns http success' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET show returns http success' do
      get :show, id: @category.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(@category.has_children?).to eq(true)
    end

    context 'AdminUser should be able to create, destroy and update categories' do
      before :each do
        sign_in @adminuser
      end

      it 'GET edit returns http success' do
        get :edit, id: @category.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'Update category and redirect to category edit page' do
        put :update, id: @child_cat.id, category: attri
        @child_cat.reload
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(categories_path)
        expect(@child_cat.name).to eq('New cat name')
      end

      it 'GET a new category' do
        get :new
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'AdminUser should be able to create a new category for actor' do
        post :create, category: attri_with_actor
        @macro.reload
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(@macro.categories.third.name).to eq('New cat name')
      end

      it 'Delete category' do
        delete :destroy, id: @category.id
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(categories_path)
        expect(Category.count).to eq(5)
      end
    end

    context 'Validation on update name' do
      before :each do
        sign_in @adminuser
      end

      render_views

      it 'AdminUser should not be able to update category without name' do
        put :update, id: @category.id, category: attri_fail
        expect(response.body).to match('can&#39;t be blank')
      end

      it 'AdminUser should not be able to create category without name' do
        post :create, category: attri_fail
        expect(response.body).to match('Please review the problems below:')
      end
    end
  end
end
