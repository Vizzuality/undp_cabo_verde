require 'rails_helper'

describe ApplicationHelper, type: :helper do
  context 'controller does not set a tab item to highlight' do
    it 'nil given and responds with false' do
      helper.instance_variable_set '@menu_highlighted', :none
      expect(helper.menu_highlight?(nil)).to eq false
    end

    it 'valid identifier give and responds with false' do
      helper.instance_variable_set '@menu_highlighted', :none
      expect(helper.menu_highlight?(:home)).to eq false
    end
  end

  context 'controller sets a tab item to highlight' do
    context 'get the user page' do
      it "returns true" do
        helper.instance_variable_set '@menu_highlighted', :users
        expect(helper.menu_highlight?(:users)).to eq true
      end
    end

    context 'get the account page' do
      it "returns true" do
        helper.instance_variable_set '@menu_highlighted', :account
        expect(helper.menu_highlight?(:account)).to eq true
      end
    end
  end
end
