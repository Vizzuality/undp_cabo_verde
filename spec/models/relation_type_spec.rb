require 'rails_helper'

RSpec.describe RelationType, type: :model do
  before :each do
    @actors_relation_type = create(:actors_relation_type)
    @acts_relation_type   = create(:acts_relation_type)
  end

  it 'Create relation types' do
    expect(@actors_relation_type.relation_category).to eq(1)
    expect(@actors_relation_type.title).to eq('partners with')
    expect(@actors_relation_type.title_reverse).to eq('partners with')
    expect(@acts_relation_type.relation_category).to eq(7)
    expect(@acts_relation_type.title).to eq('contains')
    expect(@acts_relation_type.title_reverse).to eq('belongs to')
  end
end
