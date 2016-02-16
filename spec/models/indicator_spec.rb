require 'rails_helper'

RSpec.describe Indicator, type: :model do
  before :each do
    @user        = create(:user)
    @indicator_1 = create(:indicator, user_id: @user.id)
    @indicator_2 = create(:indicator, name: 'Indicator two', user_id: @user.id)
    @act         = create(:act_meso, user_id: @user.id, indicators: [@indicator_1, @indicator_2])
    @relation_1  = ActIndicatorRelation.find_by(indicator_id: @indicator_1.id, act_id: @act.id)
    @relation_2  = ActIndicatorRelation.find_by(indicator_id: @indicator_2.id, act_id: @act.id)
  end

  it 'Create Indicator' do
    expect(@indicator_1.name).to eq('Indicator one')
    expect(@indicator_1.acts.first.name).to eq('Second one')
    expect(@indicator_1.actions?).to eq(true)
  end

  it 'Order indicator by name' do
    expect(Indicator.order(name: :asc)).to eq([@indicator_1, @indicator_2])
    expect(Indicator.count).to eq(2)
  end

  it 'Indicator name validation' do
    @indicator_reject = build(:indicator, name: '', user_id: @user.id)

    @indicator_reject.valid?
    expect {@indicator_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'Indicator with user' do
    expect(@indicator_2.user.name).to eq('Pepe Moreno')
    expect(@user.indicators.count).to eq(2)
  end

  it 'Deactivate activate indicator' do
    @indicator_2.deactivate
    expect(Indicator.count).to eq(2)
    expect(Indicator.filter_inactives.count).to eq(1)
    expect(@indicator_2.deactivated?).to be(true)
    @indicator_2.activate
    expect(@indicator_2.activated?).to be(true)
    expect(Indicator.filter_actives.count).to be(2)
  end

  context 'Add indicators to acts' do
    before :each do
      @unit       = create(:unit, user: @user)
      @act_2      = create(:act_macro, user_id: @user.id)
      @relation_3 = create(:act_indicator_relation, user_id: @user.id, indicator_id: @indicator_1.id, act_id: @act_2.id, unit_id: @unit.id)
    end

    it 'Get indicators with act relations' do
      expect(@indicator_1.acts.count).to eq(2)
      expect(@indicator_1.act_indicator_relations.count).to eq(2)
      expect(@indicator_1.act_indicator_relations.last.start_date).not_to be_nil
      expect(@indicator_1.act_indicator_relations.last.target_value).to eq(100.001)
      expect(@indicator_1.act_indicator_relations.last.target_unit_symbol).to eq('€')
      expect(@indicator_1.act_indicator_relations.last.target_unit_name).to eq('Euro')
    end
  end

  context 'Indicator with categories' do
    before :each do
      @category_1 = create(:category, type: 'SocioCulturalDomain')
      @indicator  = create(:indicator, name: 'Indicator third', user_id: @user.id, categories: [@category_1])
      @category_2 = create(:category, name: 'Category second', indicators: [@indicator])
    end

    it 'Get indicators with act relations' do
      expect(@indicator.categories.count).to eq(2)
      expect(@indicator.socio_cultural_domains.count).to eq(1)
      expect(@indicator.other_domains.count).to eq(1)
    end
  end

  context 'Add tags to indicator' do
    before :each do
      @category_1 = create(:category, type: 'SocioCulturalDomain')
      @indicator  = create(:indicator, name: 'Indicator third', user_id: @user.id, categories: [@category_1])
      @indicator.tag_list.add('tag one', 'tag two')
    end

    it 'Get indicators with act relations' do
      expect(@indicator.tag_list.count).to eq(2)
      expect(@indicator.tag_list).to eq(['tag one', 'tag two'])
    end
  end
end
