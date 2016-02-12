require 'rails_helper'

RSpec.describe Localization, type: :model do
  before :each do
    @localization = create(:localization, name: 'First Localization', web_url: 'test-web.org')
  end

  it 'Create Localization' do
    expect(@localization.name).to eq('First Localization')
    expect(@localization.lat).not_to be_nil
    expect(@localization.long).not_to be_nil
    expect(@localization.country).not_to be_nil
    expect(@localization.city).not_to be_nil
    expect(@localization.web_url).to eq('http://test-web.org')
  end
end
