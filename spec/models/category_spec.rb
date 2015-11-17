require 'rails_helper'

RSpec.describe Category, type: :model do
  before :each do
    @category  = create(:category, type: 'SocioCulturalDomain')
    @child_cat = create(:category, name: 'Category second', parent: @category)
  end

  it 'Create Category' do
    expect(@category.name).to eq('Category one')
    expect(@child_cat.name).to eq('Category second')
  end

  it 'Order category by name and count' do
    expect(Category.count).to eq(2)
    expect(SocioCulturalDomain.count).to eq(1)
    expect(OtherDomain.count).to eq(1)
  end

  it 'Fetch category parent and children' do
    expect(@category.has_children?).to eq(true)
    expect(@category.children.first.name).to eq('Category second')
    expect(@child_cat.has_parent?).to eq(true)
    expect(@child_cat.parent_name).to eq('Category one')
  end

  it 'Do not allow to create category without name' do
    @category_reject = Category.new(name: '', type: 'OtherDomain')

    @category_reject.valid?
    expect {@category_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end
end
